# encoding: utf-8
module ActiveRecord
  class Base
    def self.sqlanywhere_connection(config)
      
      if config[:connection_string]
        connection_string = config[:connection_string]
      else
        config = DEFAULT_CONFIG.merge(config)

        raise ArgumentError, "No database name was given. Please add a :database option." unless config.has_key?(:database)

        connection_string  = "ServerName=#{(config.delete(:server) || config.delete(:database))};"
        connection_string += "DatabaseName=#{config.delete(:database)};"
        connection_string += "UserID=#{config.delete(:username)};"
        connection_string += "Password=#{config.delete(:password)};"
        connection_string += "CommLinks=#{config.delete(:commlinks)};" unless config[:commlinks].nil?
        connection_string += "ConnectionName=#{config.delete(:connection_name)};" unless config[:connection_name].nil?
        connection_string += "CharSet=#{config.delete(:encoding)};" unless config[:encoding].nil?
        
        # there add all other connection settings
        config.delete(:adapter)
        config.each_pair do |k, v|
          connection_string += "#{k}=#{v};"
        end
        
        connection_string += "Idle=0" # Prevent the server from disconnecting us if we're idle for >240mins (by default)
      end

      db = SA.instance.api.sqlany_new_connection()
      
      ConnectionAdapters::SQLAnywhereAdapter.new(db, logger, connection_string)
    end
  end
  
  module ConnectionAdapters
    class SQLAnywhereAdapter
      
      def binary_to_hex_string(value)
        "0x" + value.unpack("H*")[0].scan(/../).join()
      end
      
      def ransack_table_exists?(table_name)
        ransack_tables.include?(table_name.to_s)
      end
      
      def viewed_tables(name = nil)
        list_of_tables(['view'], name)
      end
      
      def base_tables(name = nil)
        list_of_tables(['base'], name)
      end

      # Do not return SYS-owned or DBO-owned tables or RS_systabgroup-owned
      def tables(name = nil) #:nodoc:
        list_of_tables(['base', 'view'])
      end
      
      # Do not return SYS-owned or RS_systabgroup-owned
      def ransack_tables(name = nil) #:nodoc:
        sql = "SELECT table_name FROM SYS.SYSTABLE WHERE creator NOT IN (0,5)"
        exec_query(sql, name).map { |row| row["table_name"] }
      end
      
      def execute(sql, name = nil) #:nodoc:
        if name == "skip_logging"
          begin
            sql_with_user = "SET @@username='#{$username}'; #{sql}"
            stmt = SA.instance.api.sqlany_prepare(@connection, sql_with_user)
            sqlanywhere_error_test(sql) if stmt==nil
            r = SA.instance.api.sqlany_execute(stmt)
            sqlanywhere_error_test(sql) if r==0
            @affected_rows = SA.instance.api.sqlany_affected_rows(stmt)
            sqlanywhere_error_test(sql) if @affected_rows==-1
          rescue StandardError => e
            @affected_rows = 0
            raise e
          ensure
            SA.instance.api.sqlany_free_stmt(stmt)
          end
        else
          log(sql, name) { execute(sql, "skip_logging") }
        end
        @affected_rows
      end
      
      def exec_query(sql, name = nil, binds = [])
        log(sql, name, binds) do
          sql_with_user = "SET @@username='#{$username}'; #{sql}"
          stmt = SA.instance.api.sqlany_prepare(@connection, sql_with_user)
          sqlanywhere_error_test(sql) if stmt==nil
          begin
            for i in 0...binds.length
              bind_type = binds[i][0].type
              bind_value = binds[i][1]
              result, bind_param = SA.instance.api.sqlany_describe_bind_param(stmt, i)
              sqlanywhere_error_test(sql) if result==0
              
              bind_param.set_direction(1) # https://github.com/sqlanywhere/sqlanywhere/blob/master/ext/sacapi.h#L175
              if bind_value.nil?
                bind_param.set_value(nil)
              else
                # perhaps all this ought to be handled in the column class?
                case bind_type
                when :boolean
                  bind_param.set_value(bind_value ? 1 : 0)
                when :decimal
                  bind_param.set_value(bind_value.to_s)
                when :date
                  bind_param.set_value(bind_value.to_time.strftime("%F"))
                when :datetime, :time
                  bind_param.set_value(bind_value.to_time.utc.strftime("%F %T"))
                when :integer
                  bind_param.set_value(bind_value.to_i)
                when :binary
                  bind_param.set_value(bind_value)
                else
                  bind_param.set_value(bind_value)
                end
              end
              result = SA.instance.api.sqlany_bind_param(stmt, i, bind_param)
              sqlanywhere_error_test(sql) if result==0
            end
            if SA.instance.api.sqlany_execute(stmt) == 0
              sqlanywhere_error_test(sql)
            end
            fields = []
            native_types = []
            num_cols = SA.instance.api.sqlany_num_cols(stmt)
            sqlanywhere_error_test(sql) if num_cols == -1
            for i in 0...num_cols
              result, col_num, name, ruby_type, native_type, precision, scale, max_size, nullable = SA.instance.api.sqlany_get_column_info(stmt, i)
              sqlanywhere_error_test(sql) if result==0
              fields << name
              native_types << native_type
            end
            rows = []
            while SA.instance.api.sqlany_fetch_next(stmt) == 1
              row = []
              for i in 0...num_cols
                r, value = SA.instance.api.sqlany_get_column(stmt, i)
                row << native_type_to_ruby_type(native_types[i], value)
              end
              rows << row
            end
            @affected_rows = SA.instance.api.sqlany_affected_rows(stmt)
            sqlanywhere_error_test(sql) if @affected_rows==-1
          rescue StandardError => e
            @affected_rows = 0
            raise e
          ensure
            SA.instance.api.sqlany_free_stmt(stmt)
          end
          if @auto_commit
            result = SA.instance.api.sqlany_commit(@connection)
            sqlanywhere_error_test(sql) if result==0
          end
          return ActiveRecord::Result.new(fields, rows)
        end
      end
      
      protected
      def list_of_tables(types, name = nil)
        sql = "SELECT table_name FROM SYS.SYSTABLE WHERE table_type in (#{types.map{|t| quote(t)}.join(', ')}) and creator NOT IN (0,3,5)"
        select(sql, name).map { |row| row["table_name"] }
      end
      
      private
        def set_connection_options
          SA.instance.api.sqlany_execute_immediate(@connection, "SET TEMPORARY OPTION non_keywords = 'LOGIN'") rescue nil
          SA.instance.api.sqlany_execute_immediate(@connection, "SET TEMPORARY OPTION timestamp_format = 'YYYY-MM-DD HH:NN:SS'") rescue nil
          #SA.instance.api.sqlany_execute_immediate(@connection, "SET OPTION reserved_keywords = 'LIMIT'") rescue nil
          # The liveness variable is used a low-cost "no-op" to test liveness
          SA.instance.api.sqlany_execute_immediate(@connection, "CREATE VARIABLE liveness INT") rescue nil
          SA.instance.api.sqlany_execute_immediate(@connection, "CREATE VARIABLE @@username VARCHAR(30)") rescue nil
        end
    end
  end
end