# 1. Функция, осуществлющая проверку, является ли заданное целое число простым

function isprime(n::IntType) where IntType <: Integer 
    for d in 2:IntType(ceil(sqrt(n)))
        if n % d == 0
            return false
        end
    end
    return true
end
 

 
# 3. Функция, осуществляющая разложение заданное целое число на степени его простых делителей.

function factorize(n::IntType) where IntType <: Integer
    list = NamedTuple{(:div, :deg), Tuple{IntType, IntType}}[]
    for p in eratosphenes_sieve(Int(ceil(n/2)))
    k = degree(n, p) 
    if k > 0
    push!(list, (div = p, deg = k))
    end
    end
    return list
   end
   function degree(n, p) 
    k=0
    n, r = divrem(n, p)
    while n > 0 && r == 0
    k += 1
    n, r = divrem(n, p)
    end
    return k
end
 
# 4. Функция, осуществляющая вычисление среднего квадратичного отклонения (от среднего значения) заданного числового массива за один проход этого массива.

function meanstd(aaa)
    T = eltype(aaa)
    n = 0; s¹ = zero(T); s² = zero(T)
    for a ∈ aaa
    n += 1; s¹ .+= a; s² += a*a
    end
    mean = s¹ ./ n
    return mean, sqrt(s²/n - mean * mean)
end
