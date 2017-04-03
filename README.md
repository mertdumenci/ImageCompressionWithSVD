# ImageCompressionWithSVD

`ImageCompressionWithSVD` is an interactive Swift playground that demonstrates
the usage of Singular Value Decomposition for image compression.

I submitted this playground to Apple as a WWDC 2017 scholarship entry.

## Author
Mert Dumenci `mert@dumenci.me`

## Internals
`ImageCompressionWithSVD` uses the Apple `LAPACK`/`BLAS` implementations included
in `Accelerate.framework` for fast matrix operations. The playground is curiously
slow at compression, as the same processes done in the playground are instant when
done in a different target using the same `Matrix` class. (The playground is
*very* slow—`~10s` vs `0.1s`. I'm probably doing something wrong.)

See `Matrix.swift` (in playground sources) for more information about the
internal workings of this playground.

## Usage
Open `wwdc2017.playground` with Xcode/Swift Playgrounds. Read & play around!
