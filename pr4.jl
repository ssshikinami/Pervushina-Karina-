#1.Функция, вычисляющая n-ю частичную сумму ряда Тейлора (Маклорена) функции для произвольно заданного значения аргумента x
function exp_partial_sum(x::Real, n::Int)
    sum = 0.0
    term = 1.0
    for i in 0:n
        sum += term
        term *= x / (i + 1)
    end
    return sum
end
println(exp_partial_sum(5.0, 6))

#2.Функция, вычиляющая значение с машинной точностью (с максимально возможной в арифметике с плавающей точкой)
function exp_with_max_precision(x) 
    y = 1.0
    term = 1.0
    k = 1
    while y + term != y 
        term *= x / k
        y += term
        k += 1
    end
    return y
end
println(exp_with_max_precision(5.0))

#
    return x
end
