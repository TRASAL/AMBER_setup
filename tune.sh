#!/bin/bash

source ${SCENARIO}

if [ -d ${CONFS} ]
then
  rm -I ${CONFS}/*
else
  mkdir -p ${CONFS}
fi

# Padding
echo "${DEVICE_NAME} ${DEVICE_PADDING}" >> ${CONFS}/padding.conf

# Zapped channels
echo ${ZAPPED_CHANNELS} >> ${CONFS}/zapped_channels.conf

# Dedispersion
if [ !${SUBBANDING} ]
then
  echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion.conf
  ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -single_step -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -zapped_channels ${ZAPPED_CHANNELS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion.conf
else
  echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion_stepone.conf
  ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_one -beams ${BEAMS} -samples ${SAMPLES} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -input_bits ${INPUT_BITS} -zapped_channels ${ZAPPED_CHANNELS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion_stepone.conf
  echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion_steptwo.conf
  ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_two -beams ${BEAMS} -samples ${SAMPLES} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -synthesized_beams ${SYNTHESIZED_BEAMS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion_steptwo.conf
fi

# SNR before downsampling
if [ !${SUBBANDING} ]
then
  echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
  ${INSTALL_ROOT}/bin/SNRTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
else
  echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
  ${INSTALL_ROOT}/bin/SNRTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
fi

# Integration steps
echo ${INTEGRATION_STEPS} >> ${CONFS}/integration_steps.conf
for STEP in ${INTEGRATION_STEPS}
do
  if [ !${SUBBANDING} ]
  then
    # Integration
    echo -n "${DEVICE_NAME} " >> ${CONFS}/integration.conf
    ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/integration.conf
    # SNR after downsampling
    echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
    ${INSTALL_ROOT}/bin/SNRTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples `echo "${SAMPLES} / ${STEP}" | bc -q` -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
  else
    # Integration
    echo -n "${DEVICE_NAME} " >> ${CONFS}/integration.conf
    ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/integration.conf
    # SNR after downsampling
    echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
    ${INSTALL_ROOT}/bin/SNRTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples `echo "${SAMPLES} / ${STEP}" | bc -q` -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
  fi
done