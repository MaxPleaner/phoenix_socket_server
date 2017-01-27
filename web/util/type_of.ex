defmodule Util.TypeOf do
    def typeof(self) do
        cond do
            is_float(self)    -> "float"
            is_number(self)   -> "number"
            is_atom(self)     -> "atom"
            is_boolean(self)  -> "boolean"
            is_binary(self)   -> "binary"
            is_function(self) -> "function"
            is_list(self)     -> "list"
            is_tuple(self)    -> "tuple"
            true              -> "unknown"
        end    
    end
end