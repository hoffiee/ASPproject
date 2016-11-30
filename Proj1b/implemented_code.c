/*	This file contains the functions that was implemented in C. The lab_ofdm_process.c is a file with about 450 lines of codes, which is a little bit to much to include in the appendix. So this will showcase the codes that was added by us.
Author: Oscar, Rickard, Viktor, Joel
date: 2016-11-29
*/
void ofdm_demodulate(float * pSrc, float * pRe, float * pIm,  float f, int length ){
  /*
   * Demodulate a real signal (pSrc) into a complex signal (pRe and pIm)
   * with modulation center frequency f and the signal length is length
   */
	int i;
	float inc,omega=0;
	/* Add code here */
  	inc = 2*M_PI*f;
  	for (i=0; i < length; i++){
    	pRe[i] = pSrc[i]*arm_cos_f32(omega);
    	pIm[i] = -pSrc[i]*arm_sin_f32(omega);
    	omega += inc;
  }
}
void cnvt_re_im_2_cmplx( float * pRe, float * pIm, float * pCmplx, int length ){
  /*
  * Converts a complex signal in the form of two vectors (pRe and pIm)
  * into one float vector of size 2*length where the real and imaginary parts are
  * interleaved. i.e [pCmplx[0]=pRe[0], pCmplx[1]=pIm[0],pCmplx[2]=pRe[1], pCmplx[3]=pIm[1]
  * etc.
  */
  int i;
  for ( i = 0; i < length ;i++) {
    /* Add code here */ 
    pCmplx[2*i] = pRe[i];
    pCmplx[2*i+1] = pIm[i];

  }
}
void ofdm_conj_equalize(float * prxMes, float * prxPilot,
		float * ptxPilot, float * pEqualized, float * hhat_conj, int length){
/*
*   Equalize the channel by multiplying with the conjugate of the channel
*  INP:
*   prxMes[] - complex vector with received data message in frequency domain (FD)
*   prxPilot[] - complex vector with received pilot in FD
*   ptxPilot[] - complex vector with transmitted pilot in FD
*   length  - number of complex OFDM symbols
*  OUT:
*   pEqualized[] - complex vector with equalized data message (Note: only phase
*   is equalized)
*   hhat_conj[] -  complex vector with estimated conjugated channel gain
*/
	int i;
	/* Add code here */
  // Make prxPilot_conj -> prxpilot, 64 symbols, 128 values
  arm_cmplx_conj_f32(prxPilot, prxPilot, length);
  // Multiply prxPilot with ptxPilot
  arm_cmplx_mult_cmplx_f32(prxPilot, ptxPilot, hhat_conj, length);
  // Scale hhat_conj with 0.5
  arm_scale_f32(hhat_conj, 0.5, hhat_conj, length);
  // Estimate the message with hhat_conj
  arm_cmplx_mult_cmplx_f32(prxMes,hhat_conj,pEqualized,length);
/*   Estimate the conjugate of channel by multiplying the conjugate of prxPilot with
 *   ptxPilot and scale with 0.5
 *   use a combination of the functions
	arm_cmplx_conj_f32()
	arm_cmplx_mult_cmplx_f32()
  the reference page for these DSP functions can be found here:
  http://www.keil.com/pack/doc/CMSIS/DSP/html/index.html
  // Estimate the message by multiplying prxMes with the conjugate channel
  // and store it in pEqualized
*/
}