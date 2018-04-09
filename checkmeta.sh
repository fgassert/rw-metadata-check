#!/bin/bash

curl "https://api.resourcewatch.org/v1/dataset?app=rw&published=true&includes=metadata,layer,widget,vocabulary&page\[size\]=1000" > datasets.json

jq ".data[10]" < datasets.json

echo "Incomplete metadata"
echo "id, dataset" > noMetadata.csv
jq -r ".data[] | select((.attributes.metadata | length<1) or ([.attributes.metadata[] | .attributes.info.citation | not] | any)) | [.id, .attributes.name] | @csv" >> noMetadata.csv < datasets.json
wc -l noMetadata.csv

echo "No tags"
echo "id, dataset" > noTags.csv
jq -r ".data[] | select((.attributes.vocabulary | length<1) or ([.attributes.vocabulary[] | .attributes.tags | length<1] | all)) | [.id, .attributes.name] | @csv" >> noTags.csv < datasets.json
wc -l noTags.csv

echo "No widget relevant columns (Carto)"
echo "id, dataset" > cartoNoWidgetColumns.csv
jq -r ".data[] | select(.attributes.provider==\"cartodb\") | select(.attributes.metadata | length>0) | select(.attributes.widgetRelevantProps | length<1) | [.id, .attributes.name] | @csv" >> cartoNoWidgetColumns.csv < datasets.json
wc -l cartoNoWidgetColumns.csv

echo "No aliases (Carto)"
echo "id, dataset" > cartoNoAliases.csv
jq -r ".data[] | select(.attributes.provider==\"cartodb\") | select(.attributes.metadata | length > 0) | select([.attributes.metadata[] | .attributes.columns | not] | all) | [.id, .attributes.name] | @csv" >> cartoNoAliases.csv < datasets.json
wc -l cartoNoAliases.csv

echo "No default widget"
echo "id, dataset" > noDefaultWidget.csv
jq -r ".data[] | select((.attributes.widget | length < 1) or ([.attributes.widget[] | .attributes.defaultEditableWidget | not] | all)) | [.id, .attributes.name] | @csv" >> noDefaultWidget.csv < datasets.json
wc -l noDefaultWidget.csv

echo "No layer description"
echo "id, layer, dataset_id" > layerNoDescription.csv
jq -r ".data[] | select(.attributes.layer | length > 0) | .attributes.layer[] | select(.attributes.description | not) | [.id, .attributes.name, .attributes.dataset] | @csv" >> layerNoDescription.csv < datasets.json
wc -l layerNoDescription.csv

echo "No layer interaction (Carto)"
echo "id, layer, dataset_id" > cartoLayerNoInteraction.csv
jq -r ".data[] | select(.attributes.provider==\"cartodb\") | select(.attributes.layer | length > 0) | .attributes.layer[] | select(.attributes.interactionConfig.output | length < 1) | [.id, .attributes.name, .attributes.dataset] | @csv" >> cartoLayerNoInteraction.csv < datasets.json
wc -l cartoLayerNoInteraction.csv

rm -f dataStatus.zip
zip dataStatus.zip *.csv
