function read_data(file)
    lines = readlines(file)
    idx = findfirst(s -> s == "", lines)
    @show idx
    fresh_ingredient_ids = Vector{Tuple{Int, Int}}()
    for range in lines[1:idx-1]
        start, stop = parse.(Int, split(range, "-"))
        push!(fresh_ingredient_ids, (start,stop))
    end
    IDs = Int[]
    for id in lines[idx+1:end]
        num = parse(Int, id)
        push!(IDs, num)
    end
    return fresh_ingredient_ids, IDs
end

function solve_part1(fresh_ingredient_ranges, IDs)
    # Part 1
    num_fresh_ingredients = 0
    for id in IDs
        for (start, stop) in fresh_ingredient_ranges
            if start <= id <= stop
                num_fresh_ingredients += 1
                break
            end
        end
    end
    return num_fresh_ingredients
end

function merge_ranges_if_overlapping(fresh_ingredient_ranges)
    fixed_ranges = Vector{Tuple{Int, Int}}()
    # ensure order
    starts = getindex.(fresh_ingredient_ranges, 1)
    stops = getindex.(fresh_ingredient_ranges, 2)
    order = sortperm(starts)
    starts = starts[order]
    stops = stops[order]
    @show issorted(starts)
    maxloops = 10^5
    while maxloops > 0
        maxloops -= 1
        num_merges = 0
        for j in 1:length(starts)-1
            if j >= length(starts)  # we dynamically change starts
                break
            end
            npops = 0
            while j < length(stops) && stops[j] >= starts[j+1]
                # println("$(stops[j]) >= $(starts[j+1]), popping")
                num_merges += 1
                npops += 1
                popat!(starts, j+1)
                if stops[j] > stops[j+1]  # took me a while to figure it out
                    popat!(stops, j+1)
                else
                    popat!(stops, j)
                end
            end
            # @show npops
            j -= 1
        end
        # @show num_merges
        if num_merges == 0 
            break
        end
    end
    fixed_ranges = [(j, k) for (j, k) in zip(starts, stops)]
    return fixed_ranges
end

function solve_part2(fresh_ingredient_ranges)
    fixed_ranges = merge_ranges_if_overlapping(fresh_ingredient_ranges)
    @warn "" fixed_ranges
    tot_fresh_ingredients = 0
    for (start, stop) in fixed_ranges
        tot_fresh_ingredients += stop - start + 1
    end
    return tot_fresh_ingredients
end

function main(args=ARGS)
    fresh_ingredient_ranges, IDs = read_data(args)
    # return solve_part1(fresh_ingredient_ranges, IDs)
    return solve_part2(fresh_ingredient_ranges)
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
