import analysis.real
noncomputable theory
-- because reals are noncomputable
local attribute [instance] classical.decidable_inhabited classical.prop_decidable
-- because I don't know how to do inverses
-- sensibly otherwise

structure complex : Type :=
(re : ℝ) (im : ℝ)

notation `ℂ` := complex

-- definition goes outside namespace, then everything else in it?

namespace complex

-- checks for equality -- should I need these?

theorem eta (z : complex) : complex.mk z.re z.im = z :=
  cases_on z (λ _ _, rfl)

theorem eq_of_re_eq_and_im_eq (z w : complex) : z.re=w.re ∧ z.im=w.im → z=w :=
begin
intro H,rw [←eta z,←eta w,H.left,H.right],
end

theorem eq_iff_re_eq_and_im_eq (z w : complex) : z=w ↔ z.re=w.re ∧ z.im=w.im :=
begin
split,
  intro H,rw [H],split;trivial,
exact eq_of_re_eq_and_im_eq _ _,
end

theorem proj_re (r0 i0 : real) : (complex.mk r0 i0).re = r0 := rfl
theorem proj_im (r0 i0 : real) : (complex.mk r0 i0).im = i0 := rfl

-- do I also add proj_re and proj_im?

local attribute [simp] eq_iff_re_eq_and_im_eq proj_re proj_im

-- Am I right in
-- thinking that the end user should not need to
-- have to use this function?

def of_real : ℝ → ℂ := λ x, { re := x, im := 0 }

-- does one name these instances or not? I've named a random selection

instance coe_real_complex : has_coe ℝ ℂ := ⟨of_real⟩
instance : has_zero complex := ⟨of_real 0⟩
instance : has_one complex := ⟨of_real 1⟩
instance inhabited_complex : inhabited complex := ⟨0⟩


-- def i := complex.mk 0 1

/-- complex addition-/
def add : complex → complex → complex :=
λ z w, { re :=z.re+w.re, im:=z.im+w.im}

def neg : complex → complex :=
λ z, { re := -z.re, im := -z.im}

def mul : complex → complex → complex :=
λ z w, { re := z.re*w.re - z.im*w.im,
         im := z.im*w.re + z.re*w.im}

def norm_squared : complex → real :=
λ z, z.re*z.re+z.im*z.im

def inv : complex → complex :=
λ z,  { re := z.re / norm_squared z,
        im := -z.im / norm_squared z }

instance : has_add complex := ⟨complex.add⟩
instance : has_neg complex := ⟨complex.neg⟩
instance : has_sub complex := ⟨λx y, x + - y⟩
instance : has_mul complex := ⟨complex.mul⟩
instance : has_inv complex := ⟨complex.inv⟩
instance : has_div ℝ := ⟨λx y, x * y⁻¹⟩

-- I don't know how to set up
-- real.cast_zero etc (look to see
-- how it's done in real.lean?)

lemma of_real_injective : function.injective of_real :=
begin
intros x₁ x₂ H,
exact congr_arg complex.re H,
end

lemma of_real_zero : (0:complex) = of_real 0 := rfl
lemma of_real_one : (1:complex) = of_real 1 := rfl

-- set_option trace.simplify.rewrite true
-- set_option trace.simplify true
-- set_option pp.notation false

lemma of_real_neg (r : real) : -of_real r = of_real (-r) := 
begin
rw [eq_iff_re_eq_and_im_eq],
split,
-- real part works fine as it's -r = -r
  refl,
-- imag part is -0 = 0 which needs more hints.
suffices : -(0:ℝ)=0,
exact this,
simp,
end

lemma of_real_add (r s: real) : of_real r + of_real s = of_real (r+s) :=
begin
rw [eq_iff_re_eq_and_im_eq],
split,
  refl,
suffices : (0:ℝ)+0=0,
exact this,
simp,
end

lemma of_real_sub (r s:real) : of_real r - of_real s = of_real(r-s) :=
begin
rw [eq_iff_re_eq_and_im_eq],
split,
  refl,
suffices : (0:ℝ)-0=0,
exact this,
simp,
end

lemma of_real_mul (r s:real) : of_real r * of_real s = of_real (r*s) :=
begin
rw [eq_iff_re_eq_and_im_eq],
split,
  suffices : r*s-0*0=r*s,
  exact this,
  simp,
suffices : 0*s+r*0=0,
exact this,
simp
end

-- set_option pp.notation false
lemma of_real_inv (r:real) : (of_real r)⁻¹ = of_real (r⁻¹) :=
begin
rw [eq_iff_re_eq_and_im_eq],
split,
  suffices : r/(r*r+0*0) = r⁻¹,
  exact this,
  cases classical.em (r=0) with Heq Hne,
  -- this sucks
    rw [Heq],
    simp [inv_zero,div_zero],
  rw [mul_zero,add_zero,div_mul_left r Hne,inv_eq_one_div],
  suffices : -0/(r*r+0*0) = 0,
  exact this,
  rw [neg_zero,zero_div],
end

lemma of_real_abs_squared (r:real) : norm_squared (of_real r) = (abs r)*(abs r) :=
begin
rw [abs_mul_abs_self],
  suffices : r*r+0*0=r*r,
  exact this,
  simp,
end

local attribute [simp] of_real_zero of_real_one of_real_neg of_real_add
local attribute [simp] of_real_sub of_real_mul of_real_inv

instance : add_comm_group complex :=
{ add_comm_group .
  zero         := 0,
  add          := (+),
  neg          := has_neg.neg,
  zero_add     := begin
    intro z,
    apply eq_of_re_eq_and_im_eq,
    split;apply zero_add
  end,
  add_zero     := begin
    intro z,
    apply eq_of_re_eq_and_im_eq,
    split;apply add_zero
  end,
  add_comm     := begin
    intros,
    apply eq_of_re_eq_and_im_eq,
    split;apply add_comm,
  end
  ,
  add_assoc    := begin
    intros a b c,
    apply eq_of_re_eq_and_im_eq,
    split;apply add_assoc,
  end,
  add_left_neg := begin
    intros,
    apply eq_of_re_eq_and_im_eq,
    split;apply add_left_neg,
  end
}

instance : discrete_field complex :=
{ complex.add_comm_group with
  one              := 1,
  mul              := (*),
  inv              := has_inv.inv,
  mul_one          := begin
    intros,
    apply eq_of_re_eq_and_im_eq,
    split,
      unfold has_mul.mul,
      unfold semigroup.mul,
      unfold has_mul.mul,
      unfold mul,

    simp [proj_re],

    unfold has_mul.mul semigroup.mul,
    apply eq_of_re_eq_and_im_eq,
    split;unfold mul,
    rw proj_re,

      unfold has_mul.mul semigroup.mul mul,
      rw proj_re,
      change (1:complex).re with (1:ℝ),

        rw mul_one, -- dammit
      rw [mul_one],
  end,
  one_mul          := sorry,
  mul_comm         := sorry,
  mul_assoc        := sorry,
  left_distrib     := sorry,
  right_distrib    := sorry,
  zero_ne_one      := sorry,
  mul_inv_cancel   := sorry,
  inv_mul_cancel   := sorry,
  inv_zero         := sorry,
  has_decidable_eq := by apply_instance }

-- instance : topological_ring complex :=
-- { real.topological_add_group with continuous_mul := continuous_mul_real }

end complex

