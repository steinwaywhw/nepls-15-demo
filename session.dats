#define ATS_DYNLOADFLAG 0

%{^
%%
-module(session).
%%
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
%%
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/Session/mylibats2erl_all.hrl").
%%
%}

(* ***** ***** *)
(* These are low level codes, please scroll down for actual Sieve codes *)
(* ***** ***** *)

#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload "contrib/libatscc/libatscc2erl/Session/SATS/basis.sats"
staload "contrib/libatscc/libatscc2erl/Session/SATS/co-sslist.sats"
staload "contrib/libatscc/libatscc2erl/Session/SATS/sslist.sats"

staload UN = "prelude/SATS/unsafe.sats"


symintr send 
symintr recv 
symintr wait 
symintr close

overload send with chanpos_send 
overload send with channeg_recv 
overload recv with chanpos_recv 
overload recv with channeg_send
overload wait with chanpos_nil_wait
overload close with channeg_nil_close


datatype negsslist (a:vt@ype, type) = 
| nss_nil (a, chnil) of ()
| nss_cons (a, chsnd a :: sslist a) of ()

datatype possslist (a:vt@ype, type) = 
| pss_nil (a, chnil) of ()
| pss_cons (a, chsnd a :: sslist a) of ()

symintr sslist_nil
symintr sslist_cons
extern fun possslist_nil {a:vt@ype} (ch: !chanpos(sslist a) >> chanpos(chnil)): void
extern fun possslist_cons {a:vt@ype} (ch: !chanpos(sslist a) >> chanpos(chsnd(a)::sslist(a))): void
extern fun negsslist_nil {a:vt@ype} (ch: !channeg(sslist a) >> channeg(chnil)): void
extern fun negsslist_cons {a:vt@ype} (ch: !channeg(sslist a) >> channeg(chsnd(a)::sslist(a))): void 
overload sslist_nil with possslist_nil
overload sslist_nil with negsslist_nil
overload sslist_cons with possslist_cons
overload sslist_cons with negsslist_cons

symintr unroll 
extern fun unroll_pos {a:vt@ype} (!chanpos (sslist a) >> chanpos (ss)): #[ss:type] possslist (a, ss)
extern fun unroll_neg {a:vt@ype} (!channeg (sslist a) >> channeg (ss)): #[ss:type] negsslist (a, ss) 
overload unroll with unroll_pos 
overload unroll with unroll_neg

extern fun negsslist_close {a:vt@ype} (ch: channeg(sslist a)): void 
extern fun possslist_wait {a:vt@ype} (ch: chanpos(sslist a)): void
overload close with negsslist_close
overload wait with possslist_wait 

local

staload "contrib/libatscc/libatscc2erl/Session/DATS/basis_chan2.dats"

overload recv with channeg2_send
overload recv with chanpos2_recv
overload send with chanpos2_send
overload send with channeg2_recv

in 

implement possslist_nil {a} (ch) = () where {
	val untyped_ch = $UN.castvwtp1{chanpos2}(ch)
	val () = send{int}(untyped_ch, 0)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)
}

implement possslist_cons {a} (ch) = () where {
	val untyped_ch = $UN.castvwtp1{chanpos2}(ch)
	val () = send{int}(untyped_ch, 1)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)

}

implement negsslist_cons {a} (ch) = () where {
	val untyped_ch = $UN.castvwtp1{channeg2}(ch)
	val () = send{int}(untyped_ch, 1)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)	
}

implement negsslist_nil {a} (ch) = () where {
	val untyped_ch = $UN.castvwtp1{channeg2}(ch)
	val () = send{int}(untyped_ch, 0)	

	prval () = $UN.cast2void(untyped_ch)
	prval () = $UN.castview2void(ch)

}

implement unroll_pos {a} (ch) = let 
	val untyped_ch = $UN.castvwtp1{chanpos2} (ch)
	val tag = recv{int} untyped_ch
	prval _ = $UN.cast2void untyped_ch
	prval _ = $UN.castview2void ch 
in 
	if tag = 0
	then pss_nil ()
	else pss_cons ()
end

implement unroll_neg {a} (ch) = let 
	val untyped_ch = $UN.castvwtp1{channeg2} (ch)
	val tag = recv{int} untyped_ch
	prval _ = $UN.cast2void untyped_ch
	prval _ = $UN.castview2void ch 
in 
	if tag = 0
	then nss_nil ()
	else nss_cons ()
end 

implement negsslist_close {a} (ch) = let 
	val () = sslist_nil ch 
in 
	close ch 
end 

implement possslist_wait {a} (ch) = let 
	val () = sslist_nil ch 
in 
	wait ch 
end	

end

(* ***** Sieve ***** *)
(* below is the actual sieve code for normal user *)
(* ***** Sieve ***** *)

extern fun counter (n: int): channeg(sslist(int))
extern fun filter (ch: channeg(sslist(int)), p: int): channeg(sslist(int))
extern fun primes (): channeg(sslist(int))

implement counter (n) = let 
	fun loop (ch: chanpos(sslist(int)), n: int): void = let 
		val choice = unroll ch
	in 
		case+ choice of 
		| pss_nil () => wait ch 
		| pss_cons () => (send (ch, n); loop (ch, n+1))
	end
in 
	channeg_create (llam (chpos) => loop (chpos, n))
end

implement filter (ch, p) = let 
	fun get (ch: !channeg(sslist(int))): int = let 
		val _ = sslist_cons ch 
		val num = recv ch 
	in 
		if num mod p > 0
		then num 
		else get ch
	end 

	fun loop (chout: chanpos(sslist(int)), chin: channeg(sslist(int)), p: int): void = let 
		val choice = unroll chout
	in
		case+ choice of 
		| pss_nil () => (wait chout; close chin)
		| pss_cons () => (send (chout, get chin); loop (chout, chin, p)) 
	end 
in 
	channeg_create (llam chout => loop (chout, ch, p))
end

implement primes () = let 
	fun loop (chout: chanpos(sslist(int)), chin: channeg(sslist(int))): void = let
		val choice = unroll chout
	in 
		case+ choice of 
		| pss_nil () => (wait chout; close chin)
		| pss_cons () => let 
				val _ = sslist_cons chin 
				val p = recv chin 
				val _ = send (chout, p)
			in 
				loop (chout, filter (chin, p))
			end 
	end 

in 
	channeg_create (llam (chout) => loop (chout, counter 2))
end

extern fun show (n: int, ch: !channeg(sslist(int)) >> channeg(chnil)): void 
implement show (n, ch) = let 
	fun loop (n: int, ch: !channeg(sslist(int))): void = () where {
		val _ = sslist_cons ch 
		val num = recv ch 
		val _ = println! num 
		val _ = println! num
		val _ = $extfcall (void, "io:get_line", "")
		val _ = if n > 0 then loop (n-1, ch)
	}
in 
	loop (n, ch); sslist_nil ch 
end 

extern fun main0_erl (): void = "mac#"
implement main0_erl () = () where {
	val ch = primes ()
	val _ = show (10, ch)
	val _ = close ch 
//	val x = channeg_send ch 
}	

