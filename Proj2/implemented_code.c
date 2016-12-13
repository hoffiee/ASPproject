// ...  
  /* Place your code here */
  for (i = 0; i < blockSize; i++){
    // Estimate xhat with lms_state from index i, (Filter output)
    arm_dot_prod_f32(lms_coeffs, lms_state+i, LAB_LMS_TAPS, &xhat[i]);
    e[i] = x[i] - xhat[i]; // Output Error
    for (fi = 0; fi < LAB_LMS_TAPS; fi++){
      // Update Filter coefficients
      lms_coeffs[fi] += 2*lms_mu*e[i]*lms_state[fi+i]; 
    }
  }
// ...