local handle = io.popen("tmux list-sessions -F \"#{session_name}: #{?session_attached,(Attached),}\"")
if not handle then
  print("Failed to open handle")
else
  local output = handle:read("*a")
  handle:close()
  print("Output length: " .. #output)
  print("Content:\n" .. output)
  
  for line in output:gmatch("[^\r\n]+") do
      local name = line:match("^(.-):")
      print("Match: " .. (name or "nil"))
  end
end

