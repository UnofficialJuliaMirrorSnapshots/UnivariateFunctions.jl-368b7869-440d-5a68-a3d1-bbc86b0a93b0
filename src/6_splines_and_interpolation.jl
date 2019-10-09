function create_quadratic_spline(x::Array{Date,1},y::Array{<:Real,1} ; gradients::Union{Missing,Array{<:Real,1}} = missing, extrapolation::Tuple{Schumaker_ExtrapolationSchemes,Schumaker_ExtrapolationSchemes} = (Curve,Curve), left_gradient::Union{Missing,Real} = missing, right_gradient::Union{Missing,Real} = missing)
    x_as_Floats = years_from_global_base.(x)
    return create_quadratic_spline(x_as_Floats, y; gradients = gradients, extrapolation = extrapolation, left_gradient = left_gradient, right_gradient = right_gradient)
end

function create_quadratic_spline(x::Array{<:Real,1},y::Array{<:Real,1} ; gradients::Union{Missing,Array{<:Real,1}} = missing, extrapolation::Tuple{Schumaker_ExtrapolationSchemes,Schumaker_ExtrapolationSchemes} = (Curve,Curve),
                                 left_gradient::Union{Missing,Real} = missing, right_gradient::Union{Missing,Real} = missing)
    schum = Schumaker(x, y; gradients = gradients, extrapolation = extrapolation, left_gradient = left_gradient, right_gradient = right_gradient)
    return create_quadratic_spline(schum)
end

function create_quadratic_spline(schum::Schumaker)
    starts_ = schum.IntStarts_
    coefficients = schum.coefficient_matrix_
    number_of_intervals = size(coefficients)[1]
    funcs_ = Array{Sum_Of_Functions,1}(undef, number_of_intervals)
    for i in 1:number_of_intervals
        quadratic = PE_Function(coefficients[i,1], 0.0, starts_[i], 2)
        linear    = PE_Function(coefficients[i,2], 0.0, starts_[i], 1)
        constant  = PE_Function(coefficients[i,3], 0.0, 0.0       , 0)
        polynomial = Sum_Of_Functions([quadratic, linear, constant])
        funcs_[i] = polynomial
    end
    return Piecewise_Function(starts_, funcs_)
end

function create_quadratic_spline(x::Union{Array{D,1},Array{<:DatePeriod,1}},y::Array{<:Real,1}; gradients::Union{Missing,Array{<:Real,1}} = missing, extrapolation::Tuple{Schumaker_ExtrapolationSchemes,Schumaker_ExtrapolationSchemes} = (Curve,Curve),
                                 left_gradient::Union{Missing,Real} = missing, right_gradient::Union{Missing,Real} = missing) where D<:DatePeriod
    x_as_Floats = period_length.(x)
    return create_quadratic_spline(x_as_Floats, y; gradients = gradients, extrapolation = extrapolation, left_gradient = left_gradient, right_gradient = right_gradient)
end

function create_constant_interpolation_to_right(x::Array{Date,1},y::Array{<:Real,1})
    x_Float = years_from_global_base.(x)
    return create_constant_interpolation_to_right(x_Float,y)
end

function create_constant_interpolation_to_right(x::Array{<:Real,1},y::Array{<:Real,1})
    x_ = vcat(-Inf,x)
    y = vcat(y[1], y)
    funcs_ = PE_Function.(y,0.0,0.0,0)
    return Piecewise_Function(x_, funcs_)
end

function create_constant_interpolation_to_right(x::Union{Array{D,1},Array{<:DatePeriod,1}},y::Array{<:Real,1}) where D<:DatePeriod
    x_as_Floats = period_length.(x)
    return create_constant_interpolation_to_right(x_as_Floats,y)
end

function create_constant_interpolation_to_left(x::Array{Date,1},y::Array{<:Real,1})
    x_Float = years_from_global_base.(x)
    return create_constant_interpolation_to_left(x_Float,y)
end

function create_constant_interpolation_to_left(x::Array{<:Real,1},y::Array{<:Real,1})
    x_ = vcat(-Inf,x[1:(length(x)-1)])
    funcs_ = PE_Function.(y,0.0,0.0,0)
    return Piecewise_Function(x_, funcs_)
end

function create_constant_interpolation_to_left(x::Union{Array{D,1},Array{<:DatePeriod,1}},y::Array{<:Real,1}) where D<:DatePeriod
    x_as_Floats = period_length.(x)
    return create_constant_interpolation_to_left(x_as_Floats,y)
end

function create_linear_interpolation(x::Array{Date,1},y::Array{<:Real,1})
    x_Float = years_from_global_base.(x)
    return create_linear_interpolation(x_Float,y)
end

function create_linear_interpolation(x::Union{Array{D,1},Array{<:DatePeriod,1}},y::Array{<:Real,1}) where D<:DatePeriod
    x_as_Floats = period_length.(x)
    return create_linear_interpolation(x_as_Floats,y)
end

function create_linear_interpolation(x::Array{R,1},y::Array{<:Real,1}) where R<:Real
    len = length(x)
    if len < 2
        error("Insufficient data to linearly interpolate")
    end
    starts_ = Array{R,1}(undef, len-1)
    funcs_  = Array{UnivariateFunction}(undef, len-1)
    coefficient = (y[2] - y[1])/(x[2] - x[1])
    starts_[1] = -Inf
    funcs_[1]  = Sum_Of_Functions([PE_Function(y[1],0.0,0.0,0), PE_Function(coefficient,0.0,x[1],1)])
    if len > 2
        for i in 2:(len-1)
            starts_[i] = x[i]
            coefficient = (y[i+1] - y[i])/(x[i+1] - x[i])
            funcs_[i]  = Sum_Of_Functions([PE_Function(y[i],0.0,0.0,0), PE_Function(coefficient,0.0,x[i],1)])
        end
    end
    return Piecewise_Function(starts_, funcs_)
end
