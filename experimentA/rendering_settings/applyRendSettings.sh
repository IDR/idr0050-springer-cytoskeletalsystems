#!/bin/bash
#
# The render plugin currently doesn't support applying a set of rendering settings to a 
# whole dataset. This script just itereates over a tab separated mapping file which
# maps a dataset name to a renderings settings file (can be json or yml).
# It retrieves the images ids of the datasets and calls the render plugin for each
# of the images. 
#
# Note: 
# - You need to log in first before running this script.
# - If any of the datasets has more than 100 images increase the --limit parameter!

datasets_file="idr0050-datasets-renderingMapping.tsv"
images_file="idr0050-images-renderingMapping.tsv"
omero="/opt/omero/server/OMERO.server/bin/omero"
render="/opt/omero/server/OMERO.server/bin/omero render set"

while IFS='	' read -r f1 f2
do
	imageids=`$omero hql --ids-only --limit 1000 --style csv -q "select img from DatasetImageLink l join l.parent as ds join l.child as img where ds.name = '$f1'"`
	IFS=',' read -r -a array <<< $imageids
	
	for imageid in "${array[@]}"
	do
		imageid=${imageid/ */}
		if [[ $imageid == Image* ]]
		then
			printf 'Applying rendering settings %s (dataset %s) to %s \n' "$f2" "$f1" "$imageid"
			$render $imageid "$f2"
		fi
	done
done <"$datasets_file"


while IFS='	' read -r f
do
	imageids=`$omero hql --ids-only --limit 1000 --style csv -q "select img from DatasetImageLink l join l.parent as ds join l.child as img where img.name like '$f%%'"`
	IFS=',' read -r -a array <<< $imageids

	for imageid in "${array[@]}"
	do
		imageid=${imageid/ */}
		if [[ $imageid == Image* ]]
		then
			printf 'Applying rendering settings %s to %s \n' "$f.yml" "$imageid"
			$render $imageid "$f.yml"
		fi
	done
done <"$images_file"
