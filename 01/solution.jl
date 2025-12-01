#!/usr/bin/env -S julia --project=.

using DelimitedFiles


function find_password(rotations::Vector{String})::Integer
    num_times_dial_points_0 = 0
    dial_position = 50  # see instructions
    println("  Dial at $dial_position...")
    for rotation in rotations
        println("Applying $rotation...")
        sign = rotation[1] == 'L' ? -1 : +1
        distance = parse(Int, rotation[2:end])
        num_times_dial_points_0 += div(distance, 100)
        distance = mod(distance, 100)
        orig_dial = copy(dial_position)
        dial_position = dial_position + sign * distance  # new integer
        println("  raw position $dial_position")
        if sign == -1 && dial_position < 0 && orig_dial != 0  # left rotation
            num_times_dial_points_0 += 1
            println("  passing 0 once (leftward)")
        elseif sign == 1 && dial_position > 100  # right rotation
            num_times_dial_points_0 += 1
            println("  passing 0 (rightward)")
        end
        println("    nclicks at 0: $num_times_dial_points_0")
        dial_position = mod(dial_position, 100)
        if dial_position == 0
            num_times_dial_points_0 += 1
            println("  Dial at 0 (exactly)!")
        end
        println("  Dial at $dial_position...")
    end
    return num_times_dial_points_0
end

function main(args=ARGS)
    input = readdlm(args[1], '\t', String) |> vec
    return find_password(input)
end



if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
