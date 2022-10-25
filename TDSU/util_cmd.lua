function handleCommand(cmd)
    HandleQuickload(cmd)
end

function HandleQuickload(cmd)
    local words = splitString(cmd, " ")
    for index, word in ipairs(words) do
        if word == "quickload" then

            print("Loaded quicksave.")

        end
        break
    end
end
