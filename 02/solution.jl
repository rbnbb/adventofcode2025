#!/usr/bin/env -S julia --project=.

using DelimitedFiles
using Primes

function sum_invalid_ids_in_v1(range)
    sum = 0
    for n in range
        numdigits = floor(Int, log10(n)) + 1  # e.g., 2 has 1 digit, 10 has 2
        isodd(numdigits) && continue
        id = string(n)
        idx_half = div(numdigits, 2)
        if id[1:idx_half] == id[idx_half+1:end]  # invalid ID
            println("Invalid ID: $n")
            sum += n
        end
    end
    return sum
end

function sum_invalid_ids_in_v2(range)
    sum = 0
    for n in range
        numdigits = floor(Int, log10(n)) + 1  # e.g., 2 has 1 digit, 10 has 2
        id = string(n)
        for seq_len in divisors(numdigits)  # don't consider numdigits
            ntimes_seq_repeats = div(numdigits, seq_len)
            seq_len == numdigits && continue  # skip if prime
            # println("n=$n, seq_len=$seq_len, numdigits=$numdigits")
            idxs = [(1+j*seq_len):((j+1)*seq_len) for j in 0:ntimes_seq_repeats-1]
            # @show idxs
            first_sub = id[idxs[1]]
            # @show getindex.((id,), idxs)
            is_invalid = all(r -> id[r] == first_sub, idxs[2:end])
            if is_invalid  # invalid ID
                println("==Invalid ID: $n")
                sum += n
                break
            end
        end
    end
    return sum
end

function main(args=ARGS)
    id_ranges = readdlm(args, ',', String) |> vec
    sum = 0
    for s in id_ranges
        n_beg, n_end = split(s, "-")
        range = parse(Int, n_beg):parse(Int, n_end)
        sum += sum_invalid_ids_in_v2(range)
    end
    return sum
end


if basename(PROGRAM_FILE) == basename(@__FILE__)
    main()
end
