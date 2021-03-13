Require Import axioms unscoped header_extensible.

Inductive tm : Type :=
  | var_tm : nat -> tm
  | app : tm -> tm -> tm
  | lam : tm -> tm
  | const : nat -> tm
  | Plus : tm -> tm -> tm.

Definition congr_app {s0 : tm} {s1 : tm} {t0 : tm} {t1 : tm} (H0 : s0 = t0)
  (H1 : s1 = t1) : app s0 s1 = app t0 t1 :=
  eq_trans (eq_trans eq_refl (ap (fun x => app x s1) H0))
    (ap (fun x => app t0 x) H1).

Definition congr_lam {s0 : tm} {t0 : tm} (H0 : s0 = t0) : lam s0 = lam t0 :=
  eq_trans eq_refl (ap (fun x => lam x) H0).

Definition congr_const {s0 : nat} {t0 : nat} (H0 : s0 = t0) :
  const s0 = const t0 := eq_trans eq_refl (ap (fun x => const x) H0).

Definition congr_Plus {s0 : tm} {s1 : tm} {t0 : tm} {t1 : tm} (H0 : s0 = t0)
  (H1 : s1 = t1) : Plus s0 s1 = Plus t0 t1 :=
  eq_trans (eq_trans eq_refl (ap (fun x => Plus x s1) H0))
    (ap (fun x => Plus t0 x) H1).

Definition upRen_tm_tm (xi : nat -> nat) : nat -> nat := up_ren xi.

Fixpoint ren_tm (xi_tm : nat -> nat) (s : tm) : tm :=
  match s with
  | var_tm s0 => var_tm (xi_tm s0)
  | app s0 s1 => app (ren_tm xi_tm s0) (ren_tm xi_tm s1)
  | lam s0 => lam (ren_tm (upRen_tm_tm xi_tm) s0)
  | const s0 => const ((fun x => x) s0)
  | Plus s0 s1 => Plus (ren_tm xi_tm s0) (ren_tm xi_tm s1)
  end.

Definition up_tm_tm (sigma : nat -> tm) : nat -> tm :=
  scons (var_tm var_zero) (funcomp (ren_tm shift) sigma).

Fixpoint subst_tm (sigma_tm : nat -> tm) (s : tm) : tm :=
  match s with
  | var_tm s0 => sigma_tm s0
  | app s0 s1 => app (subst_tm sigma_tm s0) (subst_tm sigma_tm s1)
  | lam s0 => lam (subst_tm (up_tm_tm sigma_tm) s0)
  | const s0 => const ((fun x => x) s0)
  | Plus s0 s1 => Plus (subst_tm sigma_tm s0) (subst_tm sigma_tm s1)
  end.

Definition upId_tm_tm (sigma : nat -> tm) (Eq : forall x, sigma x = var_tm x)
  : forall x, up_tm_tm sigma x = var_tm x :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.

Fixpoint idSubst_tm (sigma_tm : nat -> tm)
(Eq_tm : forall x, sigma_tm x = var_tm x) (s : tm) : subst_tm sigma_tm s = s
:=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (idSubst_tm sigma_tm Eq_tm s0) (idSubst_tm sigma_tm Eq_tm s1)
  | lam s0 =>
      congr_lam (idSubst_tm (up_tm_tm sigma_tm) (upId_tm_tm _ Eq_tm) s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (idSubst_tm sigma_tm Eq_tm s0)
        (idSubst_tm sigma_tm Eq_tm s1)
  end.

Definition upExtRen_tm_tm (xi : nat -> nat) (zeta : nat -> nat)
  (Eq : forall x, xi x = zeta x) :
  forall x, upRen_tm_tm xi x = upRen_tm_tm zeta x :=
  fun n => match n with
           | S n' => ap shift (Eq n')
           | O => eq_refl
           end.

Fixpoint extRen_tm (xi_tm : nat -> nat) (zeta_tm : nat -> nat)
(Eq_tm : forall x, xi_tm x = zeta_tm x) (s : tm) :
ren_tm xi_tm s = ren_tm zeta_tm s :=
  match s with
  | var_tm s0 => ap var_tm (Eq_tm s0)
  | app s0 s1 =>
      congr_app (extRen_tm xi_tm zeta_tm Eq_tm s0)
        (extRen_tm xi_tm zeta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (extRen_tm (upRen_tm_tm xi_tm) (upRen_tm_tm zeta_tm)
           (upExtRen_tm_tm _ _ Eq_tm) s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (extRen_tm xi_tm zeta_tm Eq_tm s0)
        (extRen_tm xi_tm zeta_tm Eq_tm s1)
  end.

Definition upExt_tm_tm (sigma : nat -> tm) (tau : nat -> tm)
  (Eq : forall x, sigma x = tau x) :
  forall x, up_tm_tm sigma x = up_tm_tm tau x :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.

Fixpoint ext_tm (sigma_tm : nat -> tm) (tau_tm : nat -> tm)
(Eq_tm : forall x, sigma_tm x = tau_tm x) (s : tm) :
subst_tm sigma_tm s = subst_tm tau_tm s :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (ext_tm sigma_tm tau_tm Eq_tm s0)
        (ext_tm sigma_tm tau_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (ext_tm (up_tm_tm sigma_tm) (up_tm_tm tau_tm) (upExt_tm_tm _ _ Eq_tm)
           s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (ext_tm sigma_tm tau_tm Eq_tm s0)
        (ext_tm sigma_tm tau_tm Eq_tm s1)
  end.

Definition up_ren_ren_tm_tm (xi : nat -> nat) (zeta : nat -> nat)
  (rho : nat -> nat) (Eq : forall x, funcomp zeta xi x = rho x) :
  forall x, funcomp (upRen_tm_tm zeta) (upRen_tm_tm xi) x = upRen_tm_tm rho x :=
  up_ren_ren xi zeta rho Eq.

Fixpoint compRenRen_tm (xi_tm : nat -> nat) (zeta_tm : nat -> nat)
(rho_tm : nat -> nat) (Eq_tm : forall x, funcomp zeta_tm xi_tm x = rho_tm x)
(s : tm) : ren_tm zeta_tm (ren_tm xi_tm s) = ren_tm rho_tm s :=
  match s with
  | var_tm s0 => ap var_tm (Eq_tm s0)
  | app s0 s1 =>
      congr_app (compRenRen_tm xi_tm zeta_tm rho_tm Eq_tm s0)
        (compRenRen_tm xi_tm zeta_tm rho_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compRenRen_tm (upRen_tm_tm xi_tm) (upRen_tm_tm zeta_tm)
           (upRen_tm_tm rho_tm) (up_ren_ren _ _ _ Eq_tm) s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (compRenRen_tm xi_tm zeta_tm rho_tm Eq_tm s0)
        (compRenRen_tm xi_tm zeta_tm rho_tm Eq_tm s1)
  end.

Definition up_ren_subst_tm_tm (xi : nat -> nat) (tau : nat -> tm)
  (theta : nat -> tm) (Eq : forall x, funcomp tau xi x = theta x) :
  forall x, funcomp (up_tm_tm tau) (upRen_tm_tm xi) x = up_tm_tm theta x :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.

Fixpoint compRenSubst_tm (xi_tm : nat -> nat) (tau_tm : nat -> tm)
(theta_tm : nat -> tm)
(Eq_tm : forall x, funcomp tau_tm xi_tm x = theta_tm x) (s : tm) :
subst_tm tau_tm (ren_tm xi_tm s) = subst_tm theta_tm s :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (compRenSubst_tm xi_tm tau_tm theta_tm Eq_tm s0)
        (compRenSubst_tm xi_tm tau_tm theta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compRenSubst_tm (upRen_tm_tm xi_tm) (up_tm_tm tau_tm)
           (up_tm_tm theta_tm) (up_ren_subst_tm_tm _ _ _ Eq_tm) s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (compRenSubst_tm xi_tm tau_tm theta_tm Eq_tm s0)
        (compRenSubst_tm xi_tm tau_tm theta_tm Eq_tm s1)
  end.

Definition up_subst_ren_tm_tm (sigma : nat -> tm) (zeta_tm : nat -> nat)
  (theta : nat -> tm)
  (Eq : forall x, funcomp (ren_tm zeta_tm) sigma x = theta x) :
  forall x,
  funcomp (ren_tm (upRen_tm_tm zeta_tm)) (up_tm_tm sigma) x =
  up_tm_tm theta x :=
  fun n =>
  match n with
  | S n' =>
      eq_trans
        (compRenRen_tm shift (upRen_tm_tm zeta_tm) (funcomp shift zeta_tm)
           (fun x => eq_refl) (sigma n'))
        (eq_trans
           (eq_sym
              (compRenRen_tm zeta_tm shift (funcomp shift zeta_tm)
                 (fun x => eq_refl) (sigma n'))) (ap (ren_tm shift) (Eq n')))
  | O => eq_refl
  end.

Fixpoint compSubstRen_tm (sigma_tm : nat -> tm) (zeta_tm : nat -> nat)
(theta_tm : nat -> tm)
(Eq_tm : forall x, funcomp (ren_tm zeta_tm) sigma_tm x = theta_tm x) 
(s : tm) : ren_tm zeta_tm (subst_tm sigma_tm s) = subst_tm theta_tm s :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (compSubstRen_tm sigma_tm zeta_tm theta_tm Eq_tm s0)
        (compSubstRen_tm sigma_tm zeta_tm theta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compSubstRen_tm (up_tm_tm sigma_tm) (upRen_tm_tm zeta_tm)
           (up_tm_tm theta_tm) (up_subst_ren_tm_tm _ _ _ Eq_tm) s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (compSubstRen_tm sigma_tm zeta_tm theta_tm Eq_tm s0)
        (compSubstRen_tm sigma_tm zeta_tm theta_tm Eq_tm s1)
  end.

Definition up_subst_subst_tm_tm (sigma : nat -> tm) (tau_tm : nat -> tm)
  (theta : nat -> tm)
  (Eq : forall x, funcomp (subst_tm tau_tm) sigma x = theta x) :
  forall x,
  funcomp (subst_tm (up_tm_tm tau_tm)) (up_tm_tm sigma) x = up_tm_tm theta x :=
  fun n =>
  match n with
  | S n' =>
      eq_trans
        (compRenSubst_tm shift (up_tm_tm tau_tm)
           (funcomp (up_tm_tm tau_tm) shift) (fun x => eq_refl) (sigma n'))
        (eq_trans
           (eq_sym
              (compSubstRen_tm tau_tm shift (funcomp (ren_tm shift) tau_tm)
                 (fun x => eq_refl) (sigma n'))) (ap (ren_tm shift) (Eq n')))
  | O => eq_refl
  end.

Fixpoint compSubstSubst_tm (sigma_tm : nat -> tm) (tau_tm : nat -> tm)
(theta_tm : nat -> tm)
(Eq_tm : forall x, funcomp (subst_tm tau_tm) sigma_tm x = theta_tm x)
(s : tm) : subst_tm tau_tm (subst_tm sigma_tm s) = subst_tm theta_tm s :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (compSubstSubst_tm sigma_tm tau_tm theta_tm Eq_tm s0)
        (compSubstSubst_tm sigma_tm tau_tm theta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compSubstSubst_tm (up_tm_tm sigma_tm) (up_tm_tm tau_tm)
           (up_tm_tm theta_tm) (up_subst_subst_tm_tm _ _ _ Eq_tm) s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (compSubstSubst_tm sigma_tm tau_tm theta_tm Eq_tm s0)
        (compSubstSubst_tm sigma_tm tau_tm theta_tm Eq_tm s1)
  end.

Definition rinstInst_up_tm_tm (xi : nat -> nat) (sigma : nat -> tm)
  (Eq : forall x, funcomp var_tm xi x = sigma x) :
  forall x, funcomp var_tm (upRen_tm_tm xi) x = up_tm_tm sigma x :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.

Fixpoint rinst_inst_tm (xi_tm : nat -> nat) (sigma_tm : nat -> tm)
(Eq_tm : forall x, funcomp var_tm xi_tm x = sigma_tm x) (s : tm) :
ren_tm xi_tm s = subst_tm sigma_tm s :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (rinst_inst_tm xi_tm sigma_tm Eq_tm s0)
        (rinst_inst_tm xi_tm sigma_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (rinst_inst_tm (upRen_tm_tm xi_tm) (up_tm_tm sigma_tm)
           (rinstInst_up_tm_tm _ _ Eq_tm) s0)
  | const s0 => congr_const ((fun x => eq_refl x) s0)
  | Plus s0 s1 =>
      congr_Plus (rinst_inst_tm xi_tm sigma_tm Eq_tm s0)
        (rinst_inst_tm xi_tm sigma_tm Eq_tm s1)
  end.

Definition rinstInst_tm (xi_tm : nat -> nat) :
  ren_tm xi_tm = subst_tm (funcomp var_tm xi_tm) :=
  FunctionalExtensionality.functional_extensionality _ _
    (fun x => rinst_inst_tm xi_tm _ (fun n => eq_refl) x).

Definition instId_tm : subst_tm var_tm = id :=
  FunctionalExtensionality.functional_extensionality _ _
    (fun x => idSubst_tm var_tm (fun n => eq_refl) (id x)).

Definition rinstId_tm : @ren_tm id = id :=
  eq_trans (rinstInst_tm (id _)) instId_tm.

Definition varL_tm (sigma_tm : nat -> tm) :
  funcomp (subst_tm sigma_tm) var_tm = sigma_tm :=
  FunctionalExtensionality.functional_extensionality _ _ (fun x => eq_refl).

Definition varLRen_tm (xi_tm : nat -> nat) :
  funcomp (ren_tm xi_tm) var_tm = funcomp var_tm xi_tm :=
  FunctionalExtensionality.functional_extensionality _ _ (fun x => eq_refl).

Definition renRen_tm (xi_tm : nat -> nat) (zeta_tm : nat -> nat) (s : tm) :
  ren_tm zeta_tm (ren_tm xi_tm s) = ren_tm (funcomp zeta_tm xi_tm) s :=
  compRenRen_tm xi_tm zeta_tm _ (fun n => eq_refl) s.

Definition renRen'_tm (xi_tm : nat -> nat) (zeta_tm : nat -> nat) :
  funcomp (ren_tm zeta_tm) (ren_tm xi_tm) = ren_tm (funcomp zeta_tm xi_tm) :=
  FunctionalExtensionality.functional_extensionality _ _
    (fun n => renRen_tm xi_tm zeta_tm n).

Definition compRen_tm (sigma_tm : nat -> tm) (zeta_tm : nat -> nat) (s : tm)
  :
  ren_tm zeta_tm (subst_tm sigma_tm s) =
  subst_tm (funcomp (ren_tm zeta_tm) sigma_tm) s :=
  compSubstRen_tm sigma_tm zeta_tm _ (fun n => eq_refl) s.

Definition compRen'_tm (sigma_tm : nat -> tm) (zeta_tm : nat -> nat) :
  funcomp (ren_tm zeta_tm) (subst_tm sigma_tm) =
  subst_tm (funcomp (ren_tm zeta_tm) sigma_tm) :=
  FunctionalExtensionality.functional_extensionality _ _
    (fun n => compRen_tm sigma_tm zeta_tm n).

Definition renComp_tm (xi_tm : nat -> nat) (tau_tm : nat -> tm) (s : tm) :
  subst_tm tau_tm (ren_tm xi_tm s) = subst_tm (funcomp tau_tm xi_tm) s :=
  compRenSubst_tm xi_tm tau_tm _ (fun n => eq_refl) s.

Definition renComp'_tm (xi_tm : nat -> nat) (tau_tm : nat -> tm) :
  funcomp (subst_tm tau_tm) (ren_tm xi_tm) = subst_tm (funcomp tau_tm xi_tm) :=
  FunctionalExtensionality.functional_extensionality _ _
    (fun n => renComp_tm xi_tm tau_tm n).

Definition compComp_tm (sigma_tm : nat -> tm) (tau_tm : nat -> tm) (s : tm) :
  subst_tm tau_tm (subst_tm sigma_tm s) =
  subst_tm (funcomp (subst_tm tau_tm) sigma_tm) s :=
  compSubstSubst_tm sigma_tm tau_tm _ (fun n => eq_refl) s.

Definition compComp'_tm (sigma_tm : nat -> tm) (tau_tm : nat -> tm) :
  funcomp (subst_tm tau_tm) (subst_tm sigma_tm) =
  subst_tm (funcomp (subst_tm tau_tm) sigma_tm) :=
  FunctionalExtensionality.functional_extensionality _ _
    (fun n => compComp_tm sigma_tm tau_tm n).
