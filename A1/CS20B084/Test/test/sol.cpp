#include<bits/stdc++.h>
using namespace std;

typedef long long ll;

vector<vector<ll>> read_matrix(ll n)
{
    vector<vector<ll>> mat(n,vector<ll>(n));
    for(ll i=0;i<n;i++)
    {
        for(ll j=0;j<n;j++)
        {
            cin>>mat[i][j];
        }
    }

    return mat;
}

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);
    
    ll n;
    cin>>n;

    vector<vector<ll>> a = read_matrix(n);
    vector<vector<ll>> b = read_matrix(n);
    vector<vector<ll>> c = read_matrix(n);
    vector<vector<ll>> d = read_matrix(2*n);

    for(ll i=0;i<n;i++)
    {
        for(ll j=0;j<n;j++)
        {
            a[i][j]*=b[j][i];
        }
    }

    for(ll i=0;i<n;i++)
    {
        for(ll j=0;j<n;j++)
        {
            a[i][j]=max(a[i][j],c[i][j]);
        }
    }

    for(ll i=0;i<2*n;i++)
    {
        for(ll j=0;j<2*n;j++)
        {
            d[i][j]*=a[i%n][j%n];
        }
    }

    for(ll i=0;i<2*n;i++)
    {
        for(ll j=0;j<2*n;j++)
        {
            cout<<d[i][j]<<" ";
        }
        cout<<"\n";
    }
}