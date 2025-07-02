-- Checklist Program for ComputerCraft

local items = {} -- Table to store checklist items
local item_count = 0 -- Counter for the number of items

-- Function to add an item to the checklist
local function addItem(description)
  item_count = item_count + 1
  items[item_count] = {
    description = description,
    completed = false
  }
  print("Added item: " .. description)
end

-- Function to display the checklist
local function displayChecklist()
  term.clear() -- Clear the terminal
  term.setCursorPos(1, 1) -- Set cursor position to top-left
  print("--- Checklist ---")
  for i, item in pairs(items) do
    local status = item.completed and "[X]" or "[ ]" -- Display X if completed, space if not
    print(i .. ". " .. status .. " " .. item.description)
  end
  print("----------------")
end

-- Function to mark an item as complete or incomplete
local function toggleCompletion(item_number)
  if items[item_number] then
    items[item_number].completed = not items[item_number].completed
    print("Toggled completion for item " .. item_number)
  else
    print("Invalid item number.")
  end
end

-- Main program loop
while true do
  displayChecklist()
  print("Commands: add, complete, clear, quit")
  local command = read()

  if command == "add" then
    print("Enter item description:")
    local description = read()
    addItem(description)
  elseif command == "complete" then
    print("Enter item number to complete:")
    local item_number = tonumber(read())
    if item_number then
      toggleCompletion(item_number)
    else
      print("Invalid input. Please enter a number.")
    end
  elseif command == "clear" then
    items = {} -- Clears the checklist
    item_count = 0
    print("Checklist cleared.")
  elseif command == "quit" then
    print("Exiting checklist program.")
    break -- Exit the loop and end the program
  else
    print("Invalid command. Please try again.")
  end
  os.sleep(0.1) -- Prevents excessive CPU usage
end