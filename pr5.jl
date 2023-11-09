# 1. Реализовать функции, аналогичные встроенным функциям sort, sort!, sortperm, sortperm! на основе алгоритма сортировки вставками.
# При этом, при проектировании функциий, аналогичных функциям sort и sort!, требуется избежать повторного кодирования алгоритма сортировки.
# То же относится и к проектированию пары функций, аналогичных функциям sortperm, sortperm!

# Сортировка вставками O( n^2 )

function insert_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = 1
    # Инвариант: срез array[1:n] - отсортирован

    while n < length(array) 
        n += 1
        i = n

        while i > 1 && array[i - 1] > array[i]
            array[i], array[i - 1] = array[i - 1], array[i]
            i -= 1
        end

        # Утверждение: array[1] <= ... <= array[n]
    end

    return array
end

insert_sort(array::AbstractVector)::AbstractVector = insert_sort!(copy(array))

#2. Реализовать алгоритм сортировки "расчесыванием", который базируется на сортировке "пузырьком". Исследовать эффективность этого алгоритма в равнении с пузырьковой сортировкой (на больших массивах делать времннные замеры).

# Сортировка расчёской O( n^2 )

function comb_sort!(array::AbstractVector{T}, factor::Real=1.2473309) where T <: Number 
    step = length(array)

    while step >= 1
        for i in 1:length(array)-step
            if array[i] > array[i+step]
                array[i], array[i+step] = array[i+step], array[i]
            end
        end
        step = Int(floor(step/factor))
    end

    # Теперь массив почти упорядочен, осталось сделать всего несколько итераций внешнего цикла в bubble_sort!(array)
    bubble_sort!(array)
end

comb_sort(array::AbstractVector, factor::Real=1.2473309)::AbstractVector = comb_sort!(copy(array), factor)

#3. Реализовать алгоритм сортировки Шелла, который базируется на сортировке вставками.
# Исследовать эффективность этого алгоритма в равнении с сортировкой вставками (на больших массивах делать времннные замеры).

# Сортировка Шелла O( n^2 )
function shell_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = length(array)

	# Здесь последовательность шагов прореживания массива определяется генератором
    step_series = (n÷2^i for i in 1:Int(floor(log2(n)))) 

    for step in step_series
        for i in firstindex(array):step-1
            insert_sort!(@view array[i:step:end]) # - сортировка вставками выделенного (прореженного) подмассива
        end
    end
    return array
end

shell_sort(array::AbstractVector)::AbstractVector = shell_sort!(copy(array))
#4. Реализовать алгоритм сортировки слияниям

function merge_sort(arr)
    if length(arr) <= 1
        return arr
    end
    mid = length(arr) ÷ 2
    left = merge_sort(arr[1:mid])
    right = merge_sort(arr[mid+1:end])
    return merge(left, right)
end

function merge(left, right)
    result = []
    i = 1
    j = 1
    while i ≤ length(left) && j ≤ length(right)
        if left[i] ≤ right[j]
            push!(result, left[i])
            i += 1
        else
            push!(result, right[j])
            j += 1
        end
    end
    while i ≤ length(left)
        push!(result, left[i])
        i += 1
    end
    while j ≤ length(right)
        push!(result, right[j])
        j += 1
    end
    return result
end

#5 - Вычисление медианы массива на основе процедуры Хоара 

function quickselect_median(l::Array{Float64, 1})
    n = length(l)
    if n % 2 == 1
        return quickselect(l, div(n, 2))
    else
        return 0.5 * (quickselect(l, div(n, 2) - 1) +
                      quickselect(l, div(n, 2)))
    end
end

function quickselect(l::Array{Float64, 1}, k::Int)
    n = length(l)
    @assert 1 ≤ k ≤ n
    if n == 1
        @assert k == 1
        return l[1]
    end

    pivot = rand(l)

    lows = [x for x in l if x < pivot]
    highs = [x for x in l if x > pivot]
    pivots = [x for x in l if x == pivot]

    if k ≤ length(lows)
        return quickselect(lows, k)
    elseif k ≤ length(lows) + length(pivots)
        return pivots[1]
    else
        return quickselect(highs, k - length(lows) - length(pivots))
    end

end


#6 - Сортировка Хоара

function quicksort(array)
    if length(array) ≤ 1
        return array
    end
    
    pivot = rand(array) # выбрать случайный элемент в качестве опорного
    left = [x for x in array if x < pivot]
    middle = [x for x in array if x == pivot]
    right = [x for x in array if x > pivot]
    
    return quicksort(left) * middle * quicksort(right) # объединение отсортированных частей
end

#7. Реализовать алгоритм сортировки за линейное время.
function calc_sort!(A::AbstractVector{<:Integer})
    min_val, max_val = extrema(A)
    num_val = zeros(Int, max_val-min_val+1) # - число всех возможных значений
    for val in A
        num_val[val-min_val+1] += 1
    end  
    k = 0
    for (i, num) in enumerate(num_val)
        A[k+1:k+num] .= min_val+i-1
        k += num
    end
    return A
end