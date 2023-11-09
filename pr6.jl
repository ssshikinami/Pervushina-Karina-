using Plots
using LinearAlgebra

# 1. Спроектировать типы Vector2D и Segment2D с соответсвующими функциями.

Vector2D{T <: Real} = NamedTuple{(:x, :y), Tuple{T,T}}

Base. +(a::Vector2D{T}, b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .+ Tuple(b))
Base. -(a::Vector2D{T}, b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .- Tuple(b))
Base. *(α::T, a::Vector2D{T}) where T = Vector2D{T}(α.*Tuple(a))

# norm(a) - длина вектора, эта функция опредедена в LinearAlgebra
LinearAlgebra.norm(a::Vector2D) = norm(Tuple(a))

# dot(a,b)=|a||b|cos(a,b) - скалярное произведение, эта функция определена в LinearAlgebra
LinearAlgebra.dot(a::Vector2D{T}, b::Vector2D{T}) where T = dot(Tuple(a), Tuple(b))

Base. cos(a::Vector2D{T}, b::Vector2D{T}) where T = dot(a, b)/norm(a)/norm(b)

# xdot(a,b)=|a||b|sin(a,b) - косое произведение
xdot(a::Vector2D{T}, b::Vector2D{T}) where T = a.x*b.y-a.y*b.x

Base.sin(a::Vector2D{T}, b::Vector2D{T}) where T = xdot(a,b)/norm(a)/norm(b)
Base.angle(a::Vector2D{T}, b::Vector2D{T}) where T = atan(sin(a,b),cos(a,b))
Base.sign(a::Vector2D{T}, b::Vector2D{T}) where T = sign(sin(a,b))

Segment2D{T <: Real} = NamedTuple{(:A, :B), NTuple{2, Vector2D{T}}}

#= Отрисовка =#
stored_lims = [0,0,0,0]

function lims!(x1, y1, x2, y2)
	stored_lims[1] = min(x1-1, stored_lims[1])
	stored_lims[2] = min(y1-1, stored_lims[2])
	stored_lims[3] = max(x2+1, stored_lims[3])
	stored_lims[4] = max(y2+1, stored_lims[4])

	xlims!(stored_lims[1], stored_lims[3])
	ylims!(stored_lims[2], stored_lims[4])
end

lims!(x, y) = lims!(x, y, x, y)

function draw(vertices::AbstractArray{Vector2D{T}}) where T
	vertices = copy(vertices)
	push!(vertices, first(vertices))

	x = [v.x for v in vertices]
	y = [v.y for v in vertices]

	plot(x, y, color=:blue, legend=false)

	lims!( minimum(x), minimum(y), maximum(x), maximum(y) )
end

function draw(point::Segment2D{T}) where T
	plot([point.A.x, point.B.x], [point.A.y, point.B.y], color=:yellow, legend=false)

	lims!( min(point.A.x, point.B.x), min(point.A.y, point.B.y), max(point.A.x, point.B.x), max(point.A.y, point.B.y) )
end

function draw(point::Vector2D{T}) where T
	scatter!([point.x,point.x], [point.y,point.y], color=:red, markersize=5, legend=false)

	lims!( point.x , point.y)
end

function clear()
	fill!(stored_lims, 0)

	xlims!(0, 1)
	ylims!(0, 1)

	plot!()
end

#= Отрисовка =#

# 2. Написать функцию, проверяющую, лежат ли две заданные точки по одну сторону от заданной прямой (прямая задается некоторым содержащимся в ней отрезком).
function oneside(P::Vector2D{T}, Q::Vector2D{T}, s::Segment2D{T})::Bool where T
	# l - направляющий вектор прямой
	l = s.B - s.A

	# Тогда, точки , лежат по одну сторону от прямой <=> когда угол между векторами имеют один и тот же знак (отложены в одну и ту же сторону от прямой)
	return sin(l, P-s.A) * sin(l,Q-s.A) > 0
end

# 3. Написать функцию, проверяющую, лежат ли две заданные точки по одну сторону от заданной кривой (кривая задается уравнением вида F(x,y) = 0).
oneside(F::Function, P::Vector2D, Q::Vector2D)::Bool =
	( F(P...) * F(Q...) > 0 )

# 4. Написать функцию, возвращающую точку пересечения (если она существует) двух заданных отрезков.
isinner(P::Vector2D, s::Segment2D)::Bool =
	(s.A.x <= P.x <= s.B.x || s.A.x >= P.x >= s.B.x) &&
	(s.A.y <= P.y <= s.B.y || s.A.y >= P.y >= s.B.y)

function intersection(s1::Segment2D{T},s2::Segment2D{T})::Union{Vector2D{T},Nothing} where T
	A = [s1.B[2]-s1.A[2] s1.A[1]-s1.B[1]
		s2.B[2]-s2.A[2] s2.A[1]-s2.B[1]]

	b = [s1.A[2]*(s1.A[1]-s1.B[1]) + s1.A[1]*(s1.B[2]-s1.A[2])
		s2.A[2]*(s2.A[1]-s2.B[1]) + s2.A[1]*(s2.B[2]-s2.A[2])]

	x, y = A\b

	# Замечание: Если матрица A - вырожденная, то произойдет ошибка времени выполнения
	if isinner((;x, y), s1) == false || isinner((;x, y), s2) == false
		return nothing
	end

	return (;x, y) #Vector2D{T}((x,y))
end

println("Пересечение: ", intersection( (A = (x = -1.0, y = -1.0), B = (x = 1.0, y = 2.0)) , (A = (x = 1.0, y = -1.0), B = (x = -1.0, y = 3.0)) ))

#=Затем происходит вычисление алгебраической суммы углов между направлениями из заданной точки на каждые две соседние вершины многоугольника. 
Для этого используется цикл for с итерацией от первого до последнего индекса массива polygon. 
В каждой итерации вычисляется угол между векторами от текущей вершины polygon[i] до заданной точки point и от текущей вершины до следующей вершины polygon[i % lastindex(polygon) + 1]. 
Вычисленные углы суммируются с переменной sum. =#

# 5. Написать функцию, проверяющую лежит ли заданная точка внутри заданного многоугольника.
function isinside(point::Vector2D{T}, polygon::AbstractArray{Vector2D{T}})::Bool where T
	@assert length(polygon) > 2

	sum = zero(Float64)

	# Вычислить алгебраическую (т.е. с учетом знака) сумму углов, между направлениями из заданной точки на каждые две сосоедние вершины многоугольника.
	# Далее воспользоваться тем, что, если полученная сумма окажется равнной нулю, то точка лежит вне многоугольника, а если она окажется равной 360 градусам, то - внутри.
	for i in firstindex(polygon):lastindex(polygon)
		sum += angle( polygon[i] - point, polygon[i % lastindex(polygon) + 1] - point )
	end
	
	return abs(sum) > π
end

println("Внутри: ", isinside( (x=0, y=0), [(x=0, y=1), (x=1, y=-1), (x=-1, y=-1)] ))
println("Внутри: ", isinside( (x=5, y=0), [(x=0, y=1), (x=1, y=-1), (x=-1, y=-1)] ))

# 6. Написать функцию, проверяющую, является ли заданный многоугольник выпуклым.
function isconvex(polygon::AbstractArray{Vector2D{T}})::Bool where T
	@assert length(polygon) > 2

	for i in firstindex(polygon):lastindex(polygon)
		# У выпуклого многоугольника все внутренние углы будут меньше 180 градусов.
		# А у не выпуклого многоугольника обязательно найдутся, как углы меньшие, так и большие 180 градусов
		if angle( polygon[i > firstindex(polygon) ? i - 1 : lastindex(polygon)] - polygon[i] , polygon[i % lastindex(polygon) + 1] - polygon[i] ) >= π
			return false
		end
	end
	return true
end

println("Выпуклый: ",isconvex( [
		(x=0, y=1),
		(x=1, y=-1),
		(x=-1, y=-1)
	] ))