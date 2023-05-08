# Download the cladecounts files from S3 for all bioprojects

# The below code is from Jeff in Twist (with minor formatting modifications);
# it lists the locatiosn of all the cladecounts files.
#
# Note, the awk command's output includes the trailing slash, so a slash is not
# needed in the file paths in the subsequent commands.

# for bioproject in $(aws s3 ls s3://nao-mgs/ | awk '{print $NF}') ; do
#   for cladecounts in $(aws s3 ls s3://nao-mgs/${bioproject}cladecounts/ | awk '{print $NF}') ; do
#     echo s3://nao-mgs/${bioproject}cladecounts/$cladecounts
#     aws s3 cp s3://nao-mgs/${bioproject}cladecounts/$cladecounts ${bioproject}cladecounts/$cladecounts
#   done
# done

# The following code gets the projects and then syncs the cladecounts
# directories. It will output an error for cases where the project folder
# exists but the corresponding cladecounts directory does not, but continue on
# to the next project.
for bioproject in $(aws s3 ls s3://nao-mgs/ | awk '{print $NF}') ; do
  aws s3 sync s3://nao-mgs/${bioproject}cladecounts ${bioproject}cladecounts
done
