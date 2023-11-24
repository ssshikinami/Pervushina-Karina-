# 1. Функция, реализующая алгоритм быстрого возведения в степень

function deg(a, n::Int)   # t*a^n = const
    t = one(a)
    while n>0
        if mod(n, 2) == 0
            n/=2
            a *= a 
        else
            n -= 1
            t *= a
        end
    end  
    return t
end

# 2. На база этой функции написать другую функцию, возвращающую n-ый член последовательности Фибоначчи (сложность - O(log n)).

struct Matrix{T}
    a11::T
    a12::T
    a21::T
    a22::T
end

Matrix{T}() where T = Matrix{T}(zero(T), zero(T), zero(T), zero(T))

Base. one(::Type{Matrix{T}}) where T = Matrix{T}(one(T), zero(T), zero(T), one(T))

Base. one(M::Matrix{T}) where T = Matrix{T}(one(T), zero(T), zero(T), one(T))

Base. zero(::Type{Matrix{T}}) where T = Matrix{T}()

function Base. *(M1::Matrix{T}, M2::Matrix{T}) where T
    a11 = M1.a11 * M2.a11 + M1.a12 * M2.a21
    a12 = M1.a11 * M2.a12 + M1.a12 * M2.a22
    a21 = M1.a21 * M2.a11 + M1.a22 * M2.a21
    a22 = M1.a21 * M2.a12 + M1.a22 * M2.a22
    Res = Matrix{T}(a11, a12, a21, a22)
    return Res
end

function fibonachi(n::Int)
    Tmp = Matrix{Int}(1, 1, 1, 0) 
    Tmp = deg(Tmp, n)
    return Tmp.a11    
end

# 3. Функция, вычисляющая с заданной точностью $\log_a x$

function log(a, x, e) # a > 1        
    z = x
    t = 1
    y = 0
    #ИНВАРИАНТ z^t * a^y = x
    while z < 1/a || z > a || t > e 
        if z < 1/a
            z *= a 
            y -= t 
        elseif z > a
            z /= a
            y += t
        elseif t > e
            t /= 2 
            z *= z 
        end
    end
    return y
end

# 4. Функция, реализующая приближенное решение уравнения вида $f(x)=0$ методом деления отрезка пополам

function bisection(f::Function, a, b, epsilon)
    if f(a)*f(b) < 0 && a < b
        f_a = f(a)
        #ИНВАРИАНТ: f_a*f(b) < 0
        while b-a > epsilon
            t = (a+b)/2
            f_t = f(t)
            if f_t == 0
                return t
            elseif f_a*f_t < 0
                b=t
            else
                a, f_a = t, f_t
            end
        end  
        return (a+b)/2
    else
        @warn("Некоректные данные")
    end
end
