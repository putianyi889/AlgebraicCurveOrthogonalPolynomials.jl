using ClassicalOrthogonalPolynomials, ContinuumArrays, SemiclassicalOrthogonalPolynomials, LinearAlgebra, BlockBandedMatrices, BandedMatrices, GenericSVD, GenericLinearAlgebra, Test

include("OPs_inside_cubics_3_variable.jl")

@testset "Multiplication by x" begin
    α₁ = 0
    β₁ = 0
    α₂ = 0
    β₂ = 0
    nmax = 5
    b = 2.0
    X = XP(nmax,α₁,β₁,α₂,β₂,b)

    k = 0.0
    pz0 = Normalized(SemiclassicalJacobi((b+1)/2, 2k+1+β₂, α₂, 0.0))
    k = 1.0
    pz1 = Normalized(SemiclassicalJacobi((b+1)/2, 2k+1+β₂, α₂, 0.0))
    C1 = pz1\pz0
    pw = Normalized(SemiclassicalJacobi((b+1)/2, β₁, α₁, 0.0))
    Jw = jacobimatrix(pw)
    Jz0 = jacobimatrix(pz0)
    Jz1 = jacobimatrix(pz1)
    pϕw = Normalized(SemiclassicalJacobi((b+1)/2, β₁+1, α₁+1, 1))
    Jϕw = jacobimatrix(pϕw)
    ϕ = x -> (1-x^2)*(b - x)
    Pn01(n,x,z) = pz0[z,n+1]*pw[(x/z+1)/2,1]
    Pn11(n,x,z) = pz1[z,n]*z*pw[(x/z+1)/2,2]

    zv = 0.5
    xv = -0.25
    yv = zv*sqrt(ϕ(xv/zv))

# k = 0
#lhs = xv*pz0[zv,1]*zv^0*pw[(xv/zv+1)/2,1]
    lhs = xv*Pn01(0,xv,zv)
#rhs = X[1,1]*pz0[zv,1]*zv^0*pw[(xv/zv+1)/2,1] + X[1,2]*pz0[zv,2]*zv^0*pw[(xv/zv+1)/2,1] + X[1,3]*pz1[zv,1]*zv^1*pw[(xv/zv+1)/2,2]
    rhs = X[1,1]*Pn01(0,xv,zv) + X[1,2]*Pn01(1,xv,zv) + X[1,3]*Pn11(1,xv,zv)
    @test lhs ≈ rhs
    lhs = xv*Pn01(1,xv,zv)
    rhs = X[2,1]*Pn01(0,xv,zv) + X[2,2]*Pn01(1,xv,zv) + X[2,3]*Pn11(1,xv,zv) + X[2,5]*Pn01(2,xv,zv) + X[2,6]*Pn11(2,xv,zv)
#lhs = xv*pz0[zv,2]*zv^0*pw[(xv/zv+1)/2,1]
#rhs = X[2,1]*pz0[zv,1]*zv^0*pw[(xv/zv+1)/2,1] + X[2,2]*pz0[zv,2]*zv^0*pw[(xv/zv+1)/2,1] + X[2,3]*pz1[zv,1]*zv^1*pw[(xv/zv+1)/2,2]
    @test lhs ≈ rhs
    lhs = xv*Pn01(2,xv,zv)
    rhs = X[5,2]*Pn01(1,xv,zv) + X[5,3]*Pn11(1,xv,zv) + X[5,5]*Pn01(2,xv,zv) + X[5,6]*Pn11(2,xv,zv) + X[5,11]*Pn01(3,xv,zv) + X[5,12]*Pn11(3,xv,zv)
    @test lhs ≈ rhs
    lhs = xv*Pn01(nmax,xv,zv)
    r = nki2ind(nmax,0,1)
    rhs = X[r,nki2ind(nmax-1,0,1)]*Pn01(nmax-1,xv,zv) + X[r,nki2ind(nmax-1,1,1)]*Pn11(nmax-1,xv,zv) + X[r,nki2ind(nmax,0,1)]*Pn01(nmax,xv,zv) + X[r,nki2ind(nmax,1,1)]*Pn11(nmax,xv,zv) + X[r,nki2ind(nmax+1,0,1)]*Pn01(nmax+1,xv,zv) + X[r,nki2ind(nmax+1,1,1)]*Pn11(nmax+1,xv,zv)
    @test lhs ≈ rhs

    # k = 1, i = 1
    k=2
    pz2 = Normalized(SemiclassicalJacobi((b+1)/2, 2k+1+β₂, α₂, 0.0))
    Pn22(n,x,z) = pz2[z,n-1]*z^2*pw[(x/z+1)/2,3]
    lhs = xv*Pn11(1,xv,zv)
    rhs = X[3,1]*Pn01(0,xv,zv) + X[3,2]*Pn01(1,xv,zv) + X[3,3]*Pn11(1,xv,zv) + X[3,5]*Pn01(2,xv,zv) + X[3,6]*Pn11(2,xv,zv) + X[3,9]*Pn22(2,xv,zv)
    @test lhs ≈ rhs

# k = 1, i = 2
    Pn12(n,x,z) = pz1[z,n]*z*pϕw[(x/z+1)/2,1]
    Pn23(n,x,z) = pz2[z,n-1]*z^2*pϕw[(x/z+1)/2,2]
    lhs = xv*Pn12(1,xv,zv)
    rhs = X[4,4]*Pn12(1,xv,zv) + X[4,7]*Pn12(2,xv,zv) + X[4,10]*Pn23(2,xv,zv)
    @test lhs ≈ rhs;

    Pn21(n,x,z) = pz2[z,n-1]*z^2*pw[(x/z+1)/2,4]
    k=3
    pz3 = Normalized(SemiclassicalJacobi((b+1)/2, 2k+1+β₂, α₂, 0.0))
    Pn31(n,x,z) = pz3[z,n-2]*z^3*pw[(x/z+1)/2,5]

    lhs = xv*Pn21(2,xv,zv)
    row = nki2ind(2,2,1)
    rhs = X[row,nki2ind(2,2,2)]*Pn22(2,xv,zv) + X[row,nki2ind(3,2,2)]*Pn22(3,xv,zv) + X[row,nki2ind(3,3,1)]*Pn31(3,xv,zv)
    @test lhs ≈ rhs;

    lhs = xv*Pn22(2,xv,zv)
    row = nki2ind(2,2,2)
    rhs = X[row,nki2ind(1,1,1)]*Pn11(1,xv,zv) + X[row,nki2ind(2,1,1)]*Pn11(2,xv,zv) + X[row,nki2ind(3,1,1)]*Pn11(3,xv,zv) + X[row,nki2ind(2,2,1)]*Pn21(2,xv,zv) + X[row,nki2ind(3,2,1)]*Pn21(3,xv,zv)
    @test lhs ≈ rhs;

    Pn33(n,x,z) = pz3[z,n-2]*z^3*pϕw[(x/z+1)/2,3]
    Pn32(n,x,z) = pz3[z,n-2]*z^3*pϕw[(x/z+1)/2,4]
    lhs = xv*Pn23(2,xv,zv)
    row = nki2ind(2,2,3)
    rhs = X[row,nki2ind(1,1,2)]*Pn12(1,xv,zv) + X[row,nki2ind(2,1,2)]*Pn12(2,xv,zv) + X[row,nki2ind(3,1,2)]*Pn12(3,xv,zv) + X[row,nki2ind(2,2,3)]*Pn23(2,xv,zv) + X[row,nki2ind(3,2,3)]*Pn23(3,xv,zv) + X[row,nki2ind(3,3,3)]*Pn33(3,xv,zv)
    @test lhs ≈ rhs

    k=4
    pz4 = Normalized(SemiclassicalJacobi((b+1)/2, 2k+1+β₂, α₂, 0.0))
    Pn41(n,x,z) = pz4[z,n-3]*z^4*pw[(x/z+1)/2,7]
    Pn42(n,x,z) = pz4[z,n-3]*z^4*pw[(x/z+1)/2,6]
    Pn43(n,x,z) = pz4[z,n-3]*z^4*pϕw[(x/z+1)/2,5]
    k=5
    pz5 = Normalized(SemiclassicalJacobi((b+1)/2, 2k+1+β₂, α₂, 0.0))
    Pn51(n,x,z) = pz5[z,n-4]*z^5*pw[(x/z+1)/2,8]
    Pn52(n,x,z) = pz5[z,n-4]*z^5*pϕw[(x/z+1)/2,7]
    Pn53(n,x,z) = pz5[z,n-4]*z^5*pϕw[(x/z+1)/2,6]
    k=6
    pz6 = Normalized(SemiclassicalJacobi((b+1)/2, 2k+1+β₂, α₂, 0.0))
    Pn63(n,x,z) = pz6[z,n-5]*z^6*pϕw[(x/z+1)/2,8]

    lhs = xv*Pn01(nmax,xv,zv)
    r = nki2ind(nmax,0,1)
    rhs = X[r,nki2ind(nmax-1,0,1)]*Pn01(nmax-1,xv,zv) + X[r,nki2ind(nmax-1,1,1)]*Pn11(nmax-1,xv,zv) + X[r,nki2ind(nmax,0,1)]*Pn01(nmax,xv,zv) + X[r,nki2ind(nmax,1,1)]*Pn11(nmax,xv,zv) + X[r,nki2ind(nmax+1,0,1)]*Pn01(nmax+1,xv,zv) + X[r,nki2ind(nmax+1,1,1)]*Pn11(nmax+1,xv,zv)
    @test lhs ≈ rhs;

    lhs = xv*Pn11(nmax,xv,zv)
    r = nki2ind(nmax,1,1)
    rhs = X[r,nki2ind(nmax-1,0,1)]*Pn01(nmax-1,xv,zv) + X[r,nki2ind(nmax,0,1)]*Pn01(nmax,xv,zv) + X[r,nki2ind(nmax+1,0,1)]*Pn01(nmax+1,xv,zv) + X[r,nki2ind(nmax-1,2,2)]*Pn22(nmax-1,xv,zv) + X[r,nki2ind(nmax,2,2)]*Pn22(nmax,xv,zv) + X[r,nki2ind(nmax+1,2,2)]*Pn22(nmax+1,xv,zv)
    @test lhs ≈ rhs

    lhs = xv*Pn12(nmax,xv,zv)
    r = nki2ind(nmax,1,2)
    rhs = X[r,nki2ind(nmax-1,1,2)]*Pn12(nmax-1,xv,zv) + X[r,nki2ind(nmax,1,2)]*Pn12(nmax,xv,zv) + X[r,nki2ind(nmax+1,1,2)]*Pn12(nmax+1,xv,zv) + X[r,nki2ind(nmax-1,2,3)]*Pn23(nmax-1,xv,zv) + X[r,nki2ind(nmax,2,3)]*Pn23(nmax,xv,zv) + X[r,nki2ind(nmax+1,2,3)]*Pn23(nmax+1,xv,zv)
    @test lhs ≈ rhs

    lhs = xv*Pn21(nmax,xv,zv)
    r = nki2ind(nmax,2,1)
    rhs = X[r,nki2ind(nmax-1,2,2)]*Pn22(nmax-1,xv,zv) + X[r,nki2ind(nmax,2,2)]*Pn22(nmax,xv,zv) + X[r,nki2ind(nmax+1,2,2)]*Pn22(nmax+1,xv,zv) + X[r,nki2ind(nmax-1,3,1)]*Pn31(nmax-1,xv,zv) + X[r,nki2ind(nmax,3,1)]*Pn31(nmax,xv,zv) + X[r,nki2ind(nmax+1,3,1)]*Pn31(nmax+1,xv,zv)
    @test lhs ≈ rhs

    lhs = xv*Pn31(nmax,xv,zv)
    r = nki2ind(nmax,3,1)
    rhs = X[r,nki2ind(nmax-1,2,1)]*Pn21(nmax-1,xv,zv) + X[r,nki2ind(nmax,2,1)]*Pn21(nmax,xv,zv) + X[r,nki2ind(nmax+1,2,1)]*Pn21(nmax+1,xv,zv) + X[r,nki2ind(nmax-1,4,2)]*Pn42(nmax-1,xv,zv) + X[r,nki2ind(nmax,4,2)]*Pn42(nmax,xv,zv) + X[r,nki2ind(nmax+1,4,2)]*Pn42(nmax+1,xv,zv)
    @test lhs ≈ rhs;

    lhs = xv*Pn32(nmax,xv,zv)
    r = nki2ind(nmax,3,2)
    rhs = X[r,nki2ind(nmax-1,3,3)]*Pn33(nmax-1,xv,zv) + X[r,nki2ind(nmax,3,3)]*Pn33(nmax,xv,zv) + X[r,nki2ind(nmax+1,3,3)]*Pn33(nmax+1,xv,zv) + X[r,nki2ind(nmax-1,4,3)]*Pn43(nmax-1,xv,zv) + X[r,nki2ind(nmax,4,3)]*Pn43(nmax,xv,zv) + X[r,nki2ind(nmax+1,4,3)]*Pn43(nmax+1,xv,zv) + X[r,nki2ind(nmax-1,3,2)]*Pn32(nmax-1,xv,zv) + X[r,nki2ind(nmax,3,2)]*Pn32(nmax,xv,zv) + X[r,nki2ind(nmax+1,3,2)]*Pn32(nmax+1,xv,zv)
    @test lhs ≈ rhs;

    lhs = xv*Pn41(nmax,xv,zv)
    r = nki2ind(nmax,4,1)
    rhs = X[r,nki2ind(nmax-1,4,2)]*Pn42(nmax-1,xv,zv) + X[r,nki2ind(nmax,4,2)]*Pn42(nmax,xv,zv) + X[r,nki2ind(nmax+1,4,2)]*Pn42(nmax+1,xv,zv)  + X[r,nki2ind(nmax,5,1)]*Pn51(nmax,xv,zv) + X[r,nki2ind(nmax+1,5,1)]*Pn51(nmax+1,xv,zv)
    @test lhs ≈ rhs;
#lhs
#X[r,nki2ind(nmax-1,4,2)]*Pn42(nmax-1,xv,zv) + X[r,nki2ind(nmax,4,2)]*Pn42(nmax,xv,zv) + X[r,nki2ind(nmax+1,4,2)]*Pn42(nmax+1,xv,zv)

    lhs = xv*Pn52(nmax,xv,zv)
    r = nki2ind(nmax,5,2)
    rhs =  X[r,nki2ind(nmax,5,2)]*Pn52(nmax,xv,zv) + X[r,nki2ind(nmax+1,5,2)]*Pn52(nmax+1,xv,zv) + X[r,nki2ind(nmax,5,3)]*Pn53(nmax,xv,zv) + X[r,nki2ind(nmax+1,5,3)]*Pn53(nmax+1,xv,zv) + X[r,nki2ind(nmax+1,6,3)]*Pn63(nmax+1,xv,zv)
    @test lhs ≈ rhs;
end
