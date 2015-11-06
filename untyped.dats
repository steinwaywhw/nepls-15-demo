#define ATS_DYNLOADFLAG 0

(* ****** ****** *)

%{^
%%
-module(untyped).
%%
-export([main0_erl/0]).
%%
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
%%
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("./CML/CATS/CML.hrl").
%%
%} // end of [%{]

(* ****** ****** *)

#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload "contrib/libatscc/libatscc2erl/basics_erl.sats"
staload CML="./CML/SATS/CML.sats"


(* ****** ****** *)

stadef chan = $CML.chan

(* ****** ****** *)

fun counter(n: int) = let
  val outCh = $CML.channel{int}()
  fun loop(n: int): void = ($CML.send(outCh, n); loop(n+1))
  val _(*tid*) = $CML.spawn(lam () => loop(n))
in
  outCh
end // end of [counter]

(* ****** ****** *)

fun filter (p: int, inCh: chan(int)) : chan(int) = let
  val outCh = $CML.channel()
  fun loop(): void = let
    val i = $CML.recv(inCh)
  in
    if i % p != 0 then $CML.send(outCh, i); loop()
  end // end of [loop]
  val _(*tid*) = $CML.spawn(lam () => loop())
in
  outCh
end // end of [filter]

(* ****** ****** *)

fun sieve () : chan(int) = let
  val primes = $CML.channel()
  fun
  loop (ch: chan(int)): void = let
    val p0 = $CML.recv(ch)
    val () = $CML.send(primes, p0)
    val ch2 = filter(p0, ch)
  in
    loop (ch2)
  end // end of [loop]
  val _(*tid*) = $CML.spawn(lam () => loop(counter(2)))
in
  primes
end // end of [sieve]

(* ****** ****** *)



(* ****** ****** *)

extern fun main0_erl (): void = "mac#"

implement main0_erl () = () where {
	val chan = sieve()
	fun loop (): void = let 
		val p = $CML.recv(chan)
		val _ = println! p
		val _ = $extfcall (void, "io:get_line", "")
	in 
		loop()
	end 

	val _ = loop()
}



(* end of [primes.dats] *)
