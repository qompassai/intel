# /qompassai/intel/openvino/imagegen/ov_flex2_helper.py
# Qompass AI Image Gen OpenVino Flex2 Helper
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
from optimum.intel.openvino import OVDiffusionPipeline
from pipeline import Flex2Pipeline


class OVFlex2Pipeline(OVDiffusionPipeline, Flex2Pipeline):
    main_input_name = "prompt"
    export_feature = "text-to-image"
    auto_model_class = Flex2Pipeline
