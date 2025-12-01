#!/usr/bin/env -S julia --project=.

using DelimitedFiles


function find_password(rotations::Vector{String})::Integer
    num_times_dial_points_0 = 0
    dial_position = 50  # see instructions
    println("Dial at $dial_position...")
    for rotation in rotations
        println("Applying $rotation...")
        sign = rotation[1] == 'L' ? -1 : +1
        distance = parse(Int, rotation[2:end])
        dial_position = mod(dial_position + sign * distance, 100)
        println("Dial at $dial_position...")
        if dial_position == 0
            num_times_dial_points_0 += 1
        end
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
