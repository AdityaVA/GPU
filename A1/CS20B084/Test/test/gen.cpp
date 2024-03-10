#include <bits/stdc++.h>
using namespace std;

mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());

int gr(int r)
{
   uniform_int_distribution<int> uid(0,r-1);
   int val = uid(rng);
   return val+1;
}

int glr(int l, int r)
{
    int dif = r-l+1;
    int x = gr(dif) + l-1;
    return x;
}

int32_t main(int argc, char *argv[])
{
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);

    int N = glr(atoi(argv[1]),atoi(argv[2]));
    
    cout<< N << "\n";
    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
        {
            cout<<glr(0,1024)<<" ";
        }
        cout<<"\n";
    }
    cout<<"\n";

    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
        {
            cout<<glr(0,1024)<<" ";
        }
        cout<<"\n";
    }
    cout<<"\n";

    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
        {
            cout<<glr(0,1024)<<" ";
        }
        cout<<"\n";
    }
    cout<<"\n";

    for(int i=0;i<2*N;i++)
    {
        for(int j=0;j<2*N;j++)
        {
            cout<<glr(0,1024)<<" ";
        }
        cout<<"\n";
    }
}