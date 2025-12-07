using Base: SplitIterator
const SPLITTER = -55
const FREE_SPACE = 0

function set_chat_at_idx(str, idx, char)
    n = length(str)
    if 1 < idx < n
        return string(str[1:idx-1], char, str[idx+1:end])
    elseif idx == 1
        return string(char, str[idx+1:end])
    elseif idx == n
        return string(str[1:idx-1], char)
    end
end

# @show ntimelines
# # danger is overcounting similar trajectories,
# # only possible if neighboring splitter is illuminated
# splitter_to_right = pos <= max_space - 2 && M[time, pos+2] == SPLITTER
# if splitter_to_right && M[time-1, pos + 2] == beam
#     ntimelines += 1
# end
# splitter_to_left = pos >= 3 && M[time, pos-2] == SPLITTER
# if splitter_to_left && M[time-1, pos - 2] == beam
#     ntimelines += 1
# end
# # Propagate through splitter
# if pos + 1 <= max_space
#     M[time, pos+1] = beam
# end
# if pos - 1 >= 1
#     M[time, pos-1] = beam
# end

function propagate_beam!(diagram)
    sources_pos = findall(x->x=='S', diagram[1])
    nlns = length(diagram)
    num_splits = 0
    for row in 2:nlns
        new_sources = Int[]
        for pos in sources_pos
            if diagram[row][pos] == '.'
                diagram[row] = set_chat_at_idx(diagram[row], pos, '|')
                push!(new_sources, pos)
            elseif diagram[row][pos] == '^'
                num_splits += 1
                diagram[row] = set_chat_at_idx(diagram[row], pos-1, '|')
                diagram[row] = set_chat_at_idx(diagram[row], pos+1, '|')
                push!(new_sources, pos-1)
                push!(new_sources, pos+1)
            end
        end
        sources_pos = new_sources
    end
    println.(diagram)
    @show num_splits
    return num_splits
end

function _count_timelines_never_finish_bad_complexity(diagram, time, pos)
    if time == length(diagram)  # we reached the end
        return 1
    end
    if diagram[time][pos] == '.'
        return count_timelines(diagram, time+1, pos)
    elseif diagram[time][pos] == '^'
        if 1 < pos < length(diagram[time])
            return count_timelines(diagram, time, pos-1) + count_timelines(diagram, time+1, pos+1)
        elseif pos == 1
            return count_timelines(diagram, time, pos+1)
        elseif pos == length(diagram[time])
            return count_timelines(diagram, time, pos-1)
        end
    end
    return nothing
end

function matrixify(diagram)::Matrix{Int}
    M = zeros(Int, length(diagram), length(diagram[1]))
    for row in eachindex(diagram)
        for col in eachindex(diagram[row])
            M[row, col] = diagram[row][col] == '^' ? SPLITTER : FREE_SPACE
        end
    end
    return M
end

function count_timelines_dumb(diagram, time, pos)
    @show diagram time pos
    if time == size(diagram, 1)  # we reached the end
        return 1
        println("end")
    end
    if diagram[time,pos] == SPLITTER
        if 1 < pos < size(diagram, 2)
            println("split at $time, $pos")
            diagram[time, pos+1] += 1
            diagram[time, pos-1] += 1
            return count_timelines_dumb(diagram, time+1, pos-1) + count_timelines_dumb(diagram, time+1, pos+1)
        elseif pos == 1
            return count_timelines_dumb(diagram, time+1, pos+1)
            diagram[time, pos+1] += 1
        elseif pos == size(diagram, 2)
            diagram[time, pos-1] += 1
            return count_timelines_dumb(diagram, time+1, pos-1)
        end
    end
    diagram[time, pos] += 1
    return count_timelines_dumb(diagram, time+1, pos)
end

function count_timelines_good(M, orig_pos)::Int
    max_time, max_space = size(M)
    sources = [(orig_pos, 1)]
    for time in 2:max_time
        @warn "time $(time-1) $sources" M
        for (pos, beam) in sources
            if M[time,pos] >= FREE_SPACE
                # @show "beaming"
                M[time, pos] += beam  # Free propagation
            elseif M[time,pos] == SPLITTER
                if pos > 1
                    M[time, pos-1] += beam
                end
                if pos < max_space
                    M[time, pos+1] += beam
                end
            end
        end
        # @show M[time, :]
        sources = findall(x->x>0, M[time, :])
        # @show sources
        sources = [(pos, M[time, pos]) for pos in sources]
    end
    @warn "time $(size(M,2)) $sources" M
    return sum(filter(x -> x>0, M[end,:]))
end

function main(args=ARGS)
    diagram = readlines(args)
    # part 1
    # return propagate_beam!(diagram)
    # part 2
    pos = findfirst(x->x=='S', diagram[1])
    M = matrixify(diagram)
    M[1, pos] = 1
    return count_timelines_good(M, pos)
    @show count_timelines_dumb(M, 2, pos)
    @show M
    # math = read_data_cephalopod(args)
    # @show math
    # return solve_part2(math)
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
