using Base: code_typed_opaque_closure, return_types
using DelimitedFiles
using LinearAlgebra
using SHA

Point = Vector{Float64}

function read_positions(file)
    points = readdlm(file, ',', Float64) |> eachrow
    return points
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

function find_closest_pairs(vs, norm_vs)
    # assume vs corrrespond to norm_vs and they are sorted by
    closest_pairs = Tuple{Float64, Point, Point}[]  # distance, points
    largest_circuits = Vector{Tuple{Int, Vector{Point}}}
    npoints = length(vs)
    for (j, u) in enumerate(vs[1:end-1])  # loop over all points, by closeness to origin
        # find closest point to it
        for k in j+1:npoints
            v = vs[k]
            distance = norm(u - v)
             # closest_pairs is ALWAYS SORTED
            idx = searchsortedfirst(closest_pairs, distance; by=first)
            insert!(closest_pairs, idx, (distance, u, v))
            if distance > norm_vs[j] + norm_vs[k]  # violates triangle inequality
                # Surprisingly enough, this never shows nothing
                @show "triangle"
                break
            end
        end
    end
    return closest_pairs
end

function prod_three_largest_circuits(closest_points, nconnections)
    circuits = Set{}[]
    j = 1
    while j <= nconnections
        _, p1, p2 = closest_points[j]
        # println("Joining $j closest: $p1 & $p2 ...")
        in_existing_circ = false
        c1 = findfirst(c -> p1 in c, circuits)
        c2 = findfirst(c -> p2 in c, circuits)
        if isnothing(c1) && isnothing(c2)
            push!(circuits, Set([p1, p2]))
        elseif isnothing(c1) && !isnothing(c2)
            push!(circuits[c2], p1)
        elseif !isnothing(c1) && isnothing(c2)
            push!(circuits[c1], p2)
        elseif c1 != c2
            circuits[c1] = union(circuits[c1], circuits[c2])
            popat!(circuits, c2)
        end
        # @warn "" circuits 
        # @warn "" [ round(Int, sum(circ)) for circ in circuits]
        j += 1
    end
    lens = length.(circuits)
    order = sortperm(lens; rev=true)
    lens = lens[order]
    @show lens
    return prod(lens[1:3])
end

function part_2(closest_points, npoints)
    circuits = Set{}[]
    j = 1
    while true
        _, p1, p2 = closest_points[j]
        # println("Joining $j closest: $p1 & $p2 ...")
        in_existing_circ = false
        c1 = findfirst(c -> p1 in c, circuits)
        c2 = findfirst(c -> p2 in c, circuits)
        if isnothing(c1) && isnothing(c2)
            push!(circuits, Set([p1, p2]))
        elseif isnothing(c1) && !isnothing(c2)
            push!(circuits[c2], p1)
        elseif !isnothing(c1) && isnothing(c2)
            push!(circuits[c1], p2)
        elseif c1 != c2
            circuits[c1] = union(circuits[c1], circuits[c2])
            popat!(circuits, c2)
        end
        if length(circuits) == 1 && length(circuits[1]) == npoints
            return p2[1] * p1[1]
            break
        end
        @show length(circuits)
        j += 1
    end
    return nothing
end

function main(args=ARGS)
    vs = read_positions(args)  # 3d points, each point defines a vec from origin
    norm_vs = norm.(vs)  # distance to origin for each point
    # Sort by distance to origin allows leveraging distance to origin.
    order = sortperm(norm_vs)
    vs = vs[order]
    norm_vs = norm_vs[order]
    closest_pairs = find_closest_pairs(vs, norm_vs)
    return prod_three_largest_circuits(closest_pairs, 10)
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
