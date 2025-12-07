using DelimitedFiles

function read_data1(file)
    M = readdlm(file)
    @show size(M) typeof(M)
    return M
end

function read_data_cephalopod(file)
    # prepare a vector of problems tuple{op, bums}
    lines = readlines(file)
    op_positions = findall(x -> (x=='*' || x=='+'), lines[end])
    nlns = length(lines)
    nops = length(op_positions)
    math = Tuple{Char, Vector{Int}}[]
    for (j, op_pos) in enumerate(op_positions)
        nums = Int[]
        col_beg = op_pos
        col_end = if j != nops
            op_positions[j+1] - 2
        else
            maximum(length.(lines))
        end
        for k in col_beg:col_end
            # exception, maybe for last column, think about it
            col_num = 0
            for row in 1:nlns-1
                if isdigit(lines[row][k])
                    col_num = 10 * col_num + parse(Int, lines[row][k])
                end
            end
            push!(nums, col_num)
        end
        @show nums
        push!(math, (lines[end][op_pos], nums))
    end
    return math
end

function solve_part1(M::Matrix)
    grand_total = 0
    for v in eachcol(M)
        op = v[end]
        if op == "*"
            grand_total += reduce(*, v[1:end-1])
        elseif op == "+"
            grand_total += reduce(+, v[1:end-1])
        end
    end
    return grand_total
end

function solve_part2(math)
    grand_total = 0
    for (op, v) in math
        if op == '*'
            grand_total += reduce(*, v)
        elseif op == '+'
            grand_total += reduce(+, v)
        end
    end
    return grand_total
end

function main(args=ARGS)
    # M = read_data1(args)
    # return solve_part1(M)
    math = read_data_cephalopod(args)
    @show math
    return solve_part2(math)
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
