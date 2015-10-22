const PI = pi
const PI_SQU = pi^2
const term0 = 16.0/PI_SQU

function fcn_l(p, q)
    return sqrt((2*p+1) * (2*p+1) * PI_SQU + (2*q+1) * (2*q+1) * PI_SQU)
end

function fcn(n, u)
    return (2*n + 1) * PI * u
end

function soln(x, y, z, max_p, max_q)
    sum = 0
    for p = 1:(max_p + 1)

        p21y = fcn(p-1, y)
        sin_py = sin(p21y)/(2*(p-1) + 1)

        for q = 1:(max_q + 1)
            q21z = fcn(q-1, z)
            sin_qz = sin(q21z)/(2*(q-1) + 1)
            l = fcn_l(p-1, q-1)
            sinh1 = sinh(l * x)
            sinh2 = sinh(l)
            temp = (sinh1 * sin_py) * (sin_qz / sinh2)
            if (temp == temp)
                sum = sum + temp
            else
                break
            end
        end
    end
    return term0 * sum
end
          
