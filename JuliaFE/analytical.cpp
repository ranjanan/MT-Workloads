#include<cstdlib>
#include<iostream>
#include<cmath>
#include<string>
#include<cstdio>
using namespace std;
typedef double Scalar;
const Scalar PI = 3.141592653589793238462;
const Scalar PI_SQR = PI*PI;
const Scalar term0 = 16.0/(PI_SQR);

//#include<conio>

Scalar fcn_l(int p, int q)
{
 return std::sqrt((2*p+1)*(2*p+1)*PI_SQR + (2*q+1)*(2*q+1)*PI_SQR);
}

Scalar fcn(int n, Scalar u)
{
  return (2*n+1)*PI*u;
}

Scalar soln(Scalar x, Scalar y, Scalar z, int max_p, int max_q)
{
    Scalar sum = 0;
        for(int p = 0; p <= max_p; ++p) {

            const Scalar p21y = fcn(p, y);
            const Scalar sin_py = std::sin(p21y)/(2*p+1);

            for(int q=0; q<=max_q; ++q) {
            const Scalar q21z = fcn(q, z);
            const Scalar sin_qz = std::sin(q21z)/(2*q+1);

            const Scalar l = fcn_l(p, q);

            const Scalar sinh1 = std::sinh(l*x);
            const Scalar sinh2 = std::sinh(l);

            const Scalar tmp = (sinh1*sin_py)*(sin_qz/sinh2);

            //if the scalar l gets too big, sinh(l) becomes inf.
            //if that happens, tmp is a NaN.
            //crude check for NaN:
            //if tmp != tmp, tmp is NaN
                if (tmp == tmp) {
                    sum += tmp;
                }
                else {
                    //if we got a NaN, break out of this inner loop and go to
                    //the next iteration of the outer loop.
                    break;
                }
            }
    }
    return term0*sum;
}

int main(int argc, char* argv[])
{
    double a;
    //const Scalar PI = 3.141592653589793238462;
    //const Scalar PI_SQR = PI*PI;
    //const Scalar term0 = 16.0/(PI_SQR);
    double x = atof(argv[1]), y = atof(argv[2]), z = atof(argv[3]);
    int max_p = atof(argv[4]), max_q = atof(argv[5]);
    //cout<<argc<<" "<<argv[0]<<" "<<argv[1]<<" "<<argv[2]<<" "<<argv[3]<<" "<<argv[4]<<" "<<argv[5]<<" "<<endl;
    a = soln(x, y, z, max_p, max_q);
    cout<<a<<endl;
    return 0;
}



