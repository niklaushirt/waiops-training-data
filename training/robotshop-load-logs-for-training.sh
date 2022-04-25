#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# LOAD LOGS DIRECTLY INTO ELASTICSEARCH
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ADAPT VALUES
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


export APP_NAME=robot-shop
export INDEX_TYPE=logs


if [[  $VERSION == "" ]]; then
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    echo "   🔬 Setting Version to default 3.3"
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    export VERSION=3.3
fi





if [[  $WAIOPS_NAMESPACE == "" ]]; then
    # Get Namespace from Cluster 
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    echo "   🔬 Getting Installation Namespace"
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
    echo "       ✅ OK - AI Manager:               $WAIOPS_NAMESPACE"
fi

if [ ! -x "$(command -v unzip)" ]; then
      echo "❌ Unzip not installed."

      echo "❌ Aborting...."
      exit 1
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT EDIT BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   💾 Loading Logs"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "      👉 Version    : $VERSION"
echo "  "
echo "  "


# read -p "Decompress Demo Logs? [y,N] " DO_COMM
# if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   📦 Uncompressing log anomaly training files"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
unzip -o ./robot-shop/$VERSION/logs/data-log-training.zip -d ./robot-shop/$VERSION/logs #>/dev/null 2>&1
echo "  "
echo "  "
# else
#     echo "❌ Skipped"
# fi

echo "***************************************************************************************************************************************************"
echo "  "
echo "  ⏱  This will take some time (up to 45 minutes"
echo "  📥 Indexes will count up to approx 320000 and 390000 respectively."
echo "  "
echo "***************************************************************************************************************************************************"

while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done>/dev/null 2>&1&


echo ""
./training/scripts/load-es-index.sh


echo "*****************************************************************************************************************************"
echo " ✅ DONE"
echo "*****************************************************************************************************************************"
