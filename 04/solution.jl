#!/usr/bin/env -S julia --project=.

function read_binary_matrix(file)
    lines = readlines(file)
    @assert unique(length.(lines)) |> length == 1
    ncols = length(lines[1])
    nrows = length(lines)
    M = zeros(Int, nrows, ncols)
    for (j, line) in enumerate(lines)
        paper_positions = findall(x -> x == '@', line)
        M[j, paper_positions] .= 1
    end
    return M
end

function add_if_valid(M, i, j)::Int
    if 0 < i <= size(M, 1) && 0 < j <= size(M, 2)
        return M[i, j]
    end
    return 0
end

function can_be_accessed(M, i, j) # solves part 1
    sum_adjacent = 0
    neighbors = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0,1), (1, -1), (1,0 ), (1, 1)]
    for (δi, δj) in neighbors
        sum_adjacent += add_if_valid(M, i+δi, j+δj)
        if sum_adjacent >= 4
            return false
        end
    end
    return true
end

function count_accessible_rolls(M)
    num_accessible_rolls = 0
    # Now I want the sum of neighboaring
    for row in axes(M, 1), col in axes(M, 2)
        M[row, col] == 0 && continue
        if can_be_accessed(M, row, col)
            num_accessible_rolls += 1
        end
    end
    return num_accessible_rolls
end

function remove_if_possible!(M, i, j)
    sum_adjacent = 0
    neighbors = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0,1), (1, -1), (1,0 ), (1, 1)]
    for (δi, δj) in neighbors
        sum_adjacent += add_if_valid(M, i+δi, j+δj)
        if sum_adjacent >= 4
            return 0  # we can't remove it
        end
    end
    M[i, j] = 0  # remove it
    return 1
end

# BEAUTIFUL O(N) algorithm thanks to Claude Opus 4.5 <3
function remove_all_accessible(M)
    # Initial pass: find all accessible cells
    queue = Set{Tuple{Int,Int}}()
    for i in axes(M,1), j in axes(M,2)
        M[i,j] == 1 && can_be_accessed(M, i, j) && push!(queue, (i,j))
    end
    
    total_removed = 0
    while !isempty(queue)
        (i, j) = pop!(queue)
        M[i,j] == 0 && continue  # already removed
        !can_be_accessed(M, i, j) && continue  # no longer accessible
        
        M[i,j] = 0
        total_removed += 1
        
        # Only neighbors might have become newly accessible
        for (δi, δj) in NEIGHBORS
            ni, nj = i+δi, j+δj
            if 0 < ni <= size(M,1) && 0 < nj <= size(M,2) && M[ni,nj] == 1
                push!(queue, (ni, nj))
            end
        end
    end
    total_removed
end

function main(args=ARGS)
    diagram = read_binary_matrix(args)
    num_removable_rolls = 0
    num_accessible_rolls = 10^12
    while num_accessible_rolls > 0
        for row in axes(diagram, 1), col in axes(diagram, 2)
            diagram[row, col] == 0 && continue
            num_removable_rolls += remove_if_possible!(diagram, row, col)
        end
        num_accessible_rolls = count_accessible_rolls(diagram) # this is inefficient, better yet, count how many remove each round, then break when during one round U remove nothing.
    end
    # @warn "" diagram
    return num_removable_rolls
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
