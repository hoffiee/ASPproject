/*	This file contains the functions that was implemented in C. The lab_ofdm_process.c is a file with about 450 lines of codes, which is a little bit to much to include in the appendix. So this will showcase the codes that was added by us.
Author: Oscar, Rickard, Viktor, Joel
date: 2016-11-29
*/
void ofdm_demodulate(float * pSrc, float * pRe, float * pIm,  float f, int length ){
	int i;
	float inc,omega=0;
  	inc = 2*M_PI*f;
  	for (i=0; i < length; i++){
    	pRe[i] = pSrc[i]*arm_cos_f32(omega);
    	pIm[i] = -pSrc[i]*arm_sin_f32(omega);
    	omega += inc;
  }
}
void cnvt_re_im_2_cmplx( float * pRe, float * pIm, float * pCmplx, int length ){
  int i;
  for ( i = 0; i < length ;i++) {
    pCmplx[2*i] = pRe[i];
    pCmplx[2*i+1] = pIm[i];
  }
}
void ofdm_conj_equalize(float * prxMes, float * prxPilot,
		float * ptxPilot, float * pEqualized, float * hhat_conj, int length){
	int i;
  // Make prxPilot_conj -> prxpilot, 64 symbols
  arm_cmplx_conj_f32(prxPilot, prxPilot, length);
  // Multiply prxPilot with ptxPilot, 64 symbols
  arm_cmplx_mult_cmplx_f32(prxPilot, ptxPilot, hhat_conj, length);
  // Scale hhat_conj with 0.5, 2*64 = 128 elements in hhat_conj
  arm_scale_f32(hhat_conj, 0.5, hhat_conj, 2*length);
  // Estimate the message with hhat_conj 64 symbols
  arm_cmplx_mult_cmplx_f32(prxMes,hhat_conj,pEqualized,length);
}