local items = {}

local function addItem()
  print("Enter item to add:")
  local newItem = io.read()
  table.insert(items, newItem)
  print(newItem .. " added.")
end

local function viewItems()
  if #items == 0 then
    print("Checklist is empty.")
  else
    print("Checklist:")
    for i, item in ipairs(items) do
      print(i .. ". " .. item)
    end
  end
end

local function clearList()
  items = {}
  print("Checklist cleared.")
end

while true do
  print("\nMenu:")
  print("1. Add item")
  print("2. View items")
  print("3. Clear list")
  print("4. Exit")
  print("Enter choice:")
  local choice = io.read()

  if choice == "1" then
    addItem()
  elseif choice == "2" then
    viewItems()
  elseif choice == "3" then
    clearList()
  elseif choice == "4" then
    break
  else
    print("Invalid choice.")
  end
end

print("Exiting checklist.")