using DelimitedFiles
using LinearAlgebra
using SHA

const RED = 1
const GREEN = 2

Point = Vector{Float64}

function read_positions(file)
    points = readdlm(file, ',', Int) |> eachrow
    return points
end

function rectangle_area(p1, p2)
    area = prod(abs.(p2 .- p1) .+ 1)
    return area
end

function find_largest_are_rectangle(ps)
    n = length(ps)
    max_area = 0
    for i in 1:n-1  # loop over all pairs ∝N^2 complexity
        for j in i+1:n
            area = rectangle_area(ps[i], ps[j])
            if max_area < area
                max_area = area
                @show max_area ps[i] ps[j]
            end 
        end
    end
    return max_area
end

function is_colored(a::Int)
    return a == GREEN || a == RED
end

function check_color(M, a) # check if point is colored
    # we take cuts along x_a and y_a and look at successive colored points in M and then paint in-between points green, at then end M[a] is colored if a should be colored
    pts_x = findall(is_colored, M[:, a[2]]) # check vertical y=y_a
    n = length(pts_x)
    for j in 1:2:(n - n%2)
        if pts_x[j] + 1 == pts_x[j+1]
            continue
        end
        M[pts_x[j]:pts_x[j+1], :] .= GREEN
     end
    pts_y = findall(is_colored, M[a[1], :]) # check horizontal x=x_a
    n = length(pts_y)
    for j in 1:2:(n - n%2)
        if pts_y[j] + 1 == pts_y[j+1]
            continue # they were already painted
        end
        M[:, pts_y[j]:pts_y[j+1]] .= GREEN
     end
     return is_colored(M[a...])
end

function rectangle_is_colored(M, a, c)
    #check if rectangle with corners a and c is fully colored
    b = (a[1], c[2])
    d = (c[1], a[2])
    if is_colored(M[b...]) && is_colored(M[d...])  # the opposite corners are already painted
        return true
    end
    if is_colored(M[b...]) 
        return check_color(M, d)
    end
    if is_colored(M[d...]) 
        return check_color(M, b)
    end
    corners_colored = check_color(M, b) && check_color(M, d)
    if !corners_colored
        return false
    end
    for row in range(sort([a[1], c[1]])...)[2:end-1]
        for col in range(sort([a[2], c[2]])...)[2:end-1]
            if !check_color(M, [row, col])
                return false
            end
        end
    end
    println("Rectangle $a - $c is colored !")
    return true
end

function find_largest_green_red_rectangle(ps)
    npoints = length(ps)
    n = maximum(maximum.(ps))
    @show n
    M = zeros(Int, n, n)
    for i in 1:npoints  # PAINT THIS is dumb, for the problem size this need 100s GB RAM !!!
        j = if i < npoints
            i + 1
        else
            1
        end
        @show ps[i]
        M[ps[i]...] = RED
        if ps[i][1] == ps[j][1]
            start, stop = sort([ps[i][2], ps[j][2]])
            M[ps[i][1], (start+1):(stop-1)] .= GREEN
        else
            start, stop = sort([ps[i][1], ps[j][1]])
            M[(start+1):(stop-1), ps[i][2]] .= GREEN
        end
    end
    max_area = 0
    # @warn "" M
    return 0
    for i in 1:npoints-1  # now check
        for j in i+1:npoints
            area = rectangle_area(ps[i], ps[j])
            if max_area < area && rectangle_is_colored(M, ps[i], ps[j])
                max_area = area
                @show max_area ps[i] ps[j]
            end 
        end
    end

    return max_area
end

function update_deltas!(deltas, delta_pt)
    deltas[3, :] .= deltas[2, :]
    deltas[2, :] .= deltas[1, :]
    deltas[2, :] .= delta_pt
    return nothing
end

function last_3_points_make_rect(deltas)
    # 1 orthogonal to 2 and 2 orthogonal to 3
    are_orthogonal = deltas[1, :] ⋅ deltas[2, :] == 0 && deltas[2, :] ⋅ deltas[3, :] == 0
    if deltas[1, 1] == 0
        d1 = deltas[1, 2]
        d3 = deltas[3, 2]
    else
        d1 = deltas[1, 1]
        d3 = deltas[3, 1]
    end
    opposite_directions = d1 * d3 < 0
    if are_orthogonal && opposite_directions
        return true
    end
    return false
end

function update_points!(last_4_points, pt)
    last_4_points[2:4] .= last_4_points[1:3]
    last_4_points[1] = pt
    return nothing
end

function find_largest_green_red_rectangle_efficient(ps)
    npoints = length(ps)
    rectangles = Tuple(Int, Int, Int, Int)[]  # a rectangle is an inequality x1<x<x2 & y1<y<y2
    # track displacements and find |_| closed rectangles
    deltas = -42 * ones(Int, 3, 2)
    last_4_points = [ps[1], ps[1], ps[1], ps[1]]
    for i in 1:npoints  # FIND RECTANGLES
        j = if i < npoints
            i + 1
        else
            1
        end
        update_deltas!(deltas, ps[j] .- ps[i])
        update_points!(last_4_points, ps[i])
        if last_3_points_make_rect(deltas)
            push!(rectangles, ())
        end
        @show ps[i]
        M[ps[i]...] = RED
        if ps[i][1] == ps[j][1]
            start, stop = sort([ps[i][2], ps[j][2]])
            M[ps[i][1], (start+1):(stop-1)] .= GREEN
        else
            start, stop = sort([ps[i][1], ps[j][1]])
            M[(start+1):(stop-1), ps[i][2]] .= GREEN
        end
    end
    max_area = 0
    # @warn "" M
    return 0
    for i in 1:npoints-1  # now check
        for j in i+1:npoints
            area = rectangle_area(ps[i], ps[j])
            if max_area < area && rectangle_is_colored(M, ps[i], ps[j])
                max_area = area
                @show max_area ps[i] ps[j]
            end 
        end
    end

    return max_area
end

function main(args=ARGS)
    ps = read_positions(args)
    return find_largest_green_red_rectangle(ps)
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
