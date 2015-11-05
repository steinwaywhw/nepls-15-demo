#define ATS_DYNLOADFLAG 0

%{^
%%
-module(depsession).
%%
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
%%
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/Session/mylibats2erl_all.hrl").
%%
%}


#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload "contrib/libatscc/libatscc2erl/Session/SATS/basis.sats"
staload "contrib/libatscc/libatscc2erl/Session/SATS/co-sslist.sats"
staload "contrib/libatscc/libatscc2erl/Session/SATS/sslist.sats"

staload UN = "prelude/SATS/unsafe.sats"


symintr send 
symintr recv 
symintr wait 

overload send with chanpos_send 
overload send with channeg_recv 
overload recv with chanpos_recv 
overload recv with channeg_send
overload wait with chanpos_nil_wait


//abstype counterlist (a:vt@ype)

//datatype counterlist (n: int, type) = 
//| cl_nil (~1, chnil) of ()
//| cl_cons (n, chsnd (int n) :: counterlist (n+1, ))


//datatype counterlist (n: int, type) = 
//| cl_nil (~1, chnil) of ()
//| cl_cons (n, chsnd (int n) :: counterlist (n+1)) of ()


//abstype sslist (vt@ype)

datatype negsslist (a:vt@ype, b:vt@ype, type) = 
| nss_nil (a, b, chnil) of ()
| nss_cons (a, b, chsnd a :: sslist b) of ()

datatype possslist (a:vt@ype, b:vt@ype, type) = 
| pss_nil (a, b, chnil) of ()
| pss_cons (a, b,  chsnd a :: sslist b) of ()

symintr sslist_nil
symintr sslist_cons
extern fun possslist_nil {a:vt@ype} (ch: !chanpos(sslist a) >> chanpos(chnil)): void
extern fun possslist_cons {a,b:vt@ype} (ch: !chanpos(sslist a) >> chanpos(chsnd(a)::sslist(b))): void
extern fun negsslist_nil {a:vt@ype} (ch: !channeg(sslist a) >> channeg(chnil)): void
extern fun negsslist_cons {a,b:vt@ype} (ch: !channeg(sslist a) >> channeg(chsnd(a)::sslist(b))): void 
overload sslist_nil with possslist_nil
overload sslist_nil with negsslist_nil
overload sslist_cons with possslist_cons
overload sslist_cons with negsslist_cons

symintr unroll 
extern fun unroll_pos {a,b:vt@ype} (!chanpos (sslist a) >> chanpos (ss)): #[ss:type] possslist (a, b, ss)
extern fun unroll_neg {a,b:vt@ype} (!channeg (sslist a) >> channeg (ss)): #[ss:type] negsslist (a, b, ss) 
overload unroll with unroll_pos 
overload unroll with unroll_neg


local

staload "contrib/libatscc/libatscc2erl/Session/DATS/basis_chan2.dats"

overload recv with channeg2_send
overload recv with chanpos2_recv
overload send with chanpos2_send
overload send with channeg2_recv

in 

implement possslist_nil {a} (ch) = () where {
 	val _ = println! ("possslist_nil")

	val untyped_ch = $UN.castvwtp1{chanpos2}(ch)
	val () = send{int}(untyped_ch, 0)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)
}

implement possslist_cons {a,b} (ch) = () where {
	val _ = println! ("possslist_cons")

	val untyped_ch = $UN.castvwtp1{chanpos2}(ch)
	val () = send{int}(untyped_ch, 1)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)

}

implement negsslist_cons {a,b} (ch) = () where {
	val _ = println! ("negsslist_cons")

	val untyped_ch = $UN.castvwtp1{chanpos2}(ch)
	val () = send{int}(untyped_ch, 1)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)	
}

implement negsslist_nil {a} (ch) = () where {
	val _ = println! ("negsslist_nil")

	val untyped_ch = $UN.castvwtp1{chanpos2}(ch)
	val () = send{int}(untyped_ch, 0)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)

}

implement unroll_pos {a,b} (ch) = let 
	val untyped_ch = $UN.castvwtp1{chanpos2} (ch)
	val tag = recv{int} untyped_ch
	prval _ = $UN.cast2void untyped_ch
	prval _ = $UN.castview2void ch 

	val _ = println! ("unroll", tag)
in 
	if tag = 0
	then pss_nil ()
	else pss_cons ()
end

implement unroll_neg {a,b} (ch) = let 
	val untyped_ch = $UN.castvwtp1{channeg2} (ch)
	val tag = recv{int} untyped_ch
	prval _ = $UN.cast2void untyped_ch
	prval _ = $UN.castview2void ch 

	val _ = println! ("unroll", tag)
in 
	if tag = 0
	then nss_nil ()
	else nss_cons ()
end 

end


extern fun counter {n:int} (n: int n): channeg(sslist(int n))

implement counter {n} (n) = let 
	fun loop {n:int} (ch: chanpos(sslist(int n)), n: int n): void = let 
		val choice = unroll{int(n), int(n+1)} ch
		val _ = println! ("counter?")
	in 
		case+ choice of 
		| pss_nil () => wait ch 
		| pss_cons () => (send (ch, n); loop (ch, n+1))
	end
in 
	channeg_create (llam (chpos) => loop (chpos, n))
end


extern fun show {n:int} (n: int, ch: !channeg(sslist(int n))): void 
implement show (n, ch) = () where {
	val _ = println! ("show", n)
	val _ = sslist_cons ch 
	val num = recv ch 
	val _ = println! num 
	val _ = $extfcall (void, "io:get_line", "")
	val _ = if n > 0 then show (n-1, ch)
}

extern fun main0_erl (): void = "mac#"
implement main0_erl () = () where {
	val ch = counter 2
	val _ = show (10, ch)
	prval _ = $UN.cast2void ch 
}	

////
chanpos (a) >> chanpos (chsnd b :: c)

extern fun counter {n:int} (n: int n): channeg (counterlist n)

implement counter {n} (n) = let 
	fun loop (ch: chanpos (counterlist n), n: int n): void = let 
		val _ = 

////
extern fun counter


////
datatype numlist (n: int) = 
| numlist_nil (~1) of ()
| numlist_cons (n) of (int n, numlist (n+1))

datatype filterlist (int, int) = 
| filterlist_nil (~1) of ()
| {n,p:int | n mod p > 0} filterlist_cons (n, p) of (n, filterlist (n+1, p))
| {n,p:int | n mod p == 0} filterlist_cons (n, p) of (filterlist (n+1))
////
abstype rpt (a:vt@ype)
extern fun unroll_pos {a:vt@ype} (!chanpos (rpt a) >> chanpos (chsnd a :: rpt a)): void
extern fun unroll_neg {a:vt@ype} (!channeg (rpt a) >> channeg (chsnd a :: rpt a)): void 
overload unroll with unroll_pos 
overload unroll with unroll_neg

implement unroll_pos {a} (ch) = () where {
	prval _ = $UN.castview2void (ch)
}

implement unroll_neg {a} (ch) = () where {
	prval _ = $UN.castview2void (ch)
}


(* ***** Sieve ***** *)

extern fun counter {n:nat} (n: int n): channeg (rpt int)
extern fun filter (channeg (rpt int), p: int): channeg (rpt int)
extern fun primes (): channeg (rpt int)
extern fun sieve (): void 

implement counter (n) = let 

	fun loop (ch: chanpos (rpt int), n: int): void = let
		val _ = unroll ch
		val _ = send (ch, n)
	in 
		loop (ch, n+1)
	end

in 
	channeg_create (llam (ch) => loop (ch, n))
end 

implement filter (ch, p) = let 

	fun loop (chout: chanpos (rpt int), chin: channeg (rpt int), p: int): void = let 
		val _ = unroll chin 
		val num = recv chin 
		val _ = if num mod p > 0 then (unroll chout; send (chout, num))
	in 
		loop (chout, chin, p)
	end 

in 
	channeg_create (llam chout => loop (chout, ch, p))
end 

implement primes () = let 
	
	fun loop (chout: chanpos (rpt int), chin: channeg (rpt int)): void = let 
		val _ = unroll chin 
		val p = recv chin
		val _ = unroll chout 
		val _ = send (chout, p)
	in 
		loop (chout, filter (chin, p))
	end

in 
	channeg_create (llam chout => loop (chout, counter 2))
end 

implement sieve () = let 
	
	fun loop (ch: channeg (rpt int)): void = let 
		val _ = unroll ch 
		val p = recv ch 
		val _ = println! p 
		val _ = $extfcall (int, "io:get_line", "")
	in 
		loop ch
	end

in 
	loop (primes ())
end 

extern fun main0_erl (): void = "mac#"
implement main0_erl () = () where {
	val _ = sieve ()
}


 
