#!/usr/bin/env -S julia --project=.

using DelimitedFiles

function find_largest_joltage_v2(digits::Vector{<:Integer}, ndigits_to_right = 0)
    n = length(digits)
    big_digit, pos = findmax(digits)
    ndigits_to_right == 0 && return big_digit
    if n - pos < ndigits_to_right
        for d in big_digit:-1:1
            idx = findfirst(x -> x==d, digits)
            isnothing(idx) && continue
            # @show d 
            if n - idx >= ndigits_to_right
                big_digit, pos = digits[idx], idx
                # println("Found $big_digit among $digits ...")
                break
            end
        end
    end
    return 10^ndigits_to_right * big_digit + find_largest_joltage_v2(digits[pos+1:end], ndigits_to_right-1)
end

function largest_joltage_using_v1(battery_bank::Vector{<:Integer})
    # idea: start with largest digit 9 and go down, find the left one
    nbatteries = length(battery_bank)
    big_digit, pos = findmax(battery_bank)
    if pos == nbatteries
        for d in big_digit:-1:1
            idx = findfirst(x -> x==d, battery_bank)
            if idx != nbatteries
                big_digit, pos = battery_bank[idx], idx
                break
            end
        end
    end
    second_largest = maximum(battery_bank[pos+1:end])
    return 10 * big_digit + second_largest
end

function main(args=ARGS)
    battery_banks = readdlm(args, ',', String) |> vec
    total_joltage = 0
    for b in battery_banks
        battery_bank = [parse(Int, dig) for dig in b]
        j = find_largest_joltage_v2(battery_bank, 11)
        # @show b j
        total_joltage += j
    end
    return total_joltage
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
