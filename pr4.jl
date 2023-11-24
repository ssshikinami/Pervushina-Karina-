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

#3.Функция, вычисляющая функцию Бесселя (обобщение функции синуса, колебание струны с переменным толщеной, натяжением) 
#заданного целого неотрицательного порядка по ее ряду Тейлора с машинной точностью.
using Plots
function bessel(M::Integer, x::Real)
    sqrx = x*x
    a = 1/factorial(M)
    m = 1
    s = 0 
    while s + a != s
        s += a
        a = -a * sqrx /(m*(M+m)*4)
        m += 1
    end
    return s*(x/2)^M
end

values = 0:0.1:20
myPlot = plot()
for m in 0:5
	plot!(myPlot, values, bessel.(m, values))
end
display(myPlot)

#4.Реализовать алгорим, реализующий обратный ход алгоритма Жордана-Гаусса
using LinearAlgebra
function jordan_gauss(A::AbstractMatrix{T}, b::AbstractVector{T})::AbstractVector{T} where T
    @assert size(A, 1) == size(A, 2)
    n = size(A, 1) 
    x = zeros(T, n)
    for i in n:-1:1
        x[i] = b[i]
        for j in i+1:n
            x[i] =fma(-x[j] ,A[i,j] , x[i])
        end
        x[i] /= A[i,i]
    end
    return x
end
