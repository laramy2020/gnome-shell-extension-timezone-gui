#!/bin/bash
#create timezone varable
zoneinfo=$(cd /usr/share/zoneinfo && tree -fi | sed 's/\.\///' | sed '$ d' |  sed '$ d' | grep '\/' | tr '\n' '\|')
#backup people.json
cp ~/people.json ~/people.json.`date +"%m-%d-%y-_-%T"` 2>&1
#Array set to newline seperation to allow naming structures like Last, First M.
IFS=$'|'

#Prompt user for info and output to a temp file (looking to add this into one command).
zenity --forms --title="Add Friend" --text="Enter information about your friend." --add-entry="Name" --add-combo="Timezone" --add-entry="Avatar" --add-entry="Gravatar" --add-entry="Github" --add-entry="City" --combo-values="$zoneinfo" > .tmp.info
if [ $? -eq 1 ]
then
	exit 1
fi

#import info to array
tzinfo=(`cat ".tmp.info" ` )

#remove the temp file
rm .tmp.info

#setup timezone varable for mandatory use in people.json

tzhold=${tzinfo[1]}
#if ${tzinfo[1]} is null warn user and ask again (currently dose not repopulate boxes, working on that).
while [ $tzhold == ${tzinfo[1]} ] 
do
	zenity --error --text "A timezone must be selected."
        zenity --forms --title="Add Friend" --text="Enter information about your friend." --add-entry="Name" --add-combo="Timezone" --add-entry="Avatar" --add-entry="Gravatar" --add-entry="Github" --add-entry="City" --combo-values="$zoneinfo" > .tmp.info
	if [ $? -eq 1 ]
	then
		exit 1
	fi
       tzinfo=(`cat ".tmp.info" ` )
       rm .tmp.info
done

#setup other varables
name=${tzinfo[0]}
github=${tzinfo[4]}
avatar=${tzinfo[2]}
gravatar=${tzinfo[3]}
city=${tzinfo[5]}

#check to see if people.json is empty/exists. if so add starting brackets (ex [{)
fexists=$(ls -la ~/people.json 2>&1)
if [ "$fexists" == "ls: cannot access '$HOME/people.json': No such file or directory" ]
then
	touch ~/people.json
fi

nullcheck=$(<~/people.json)
if [ -z "$nullcheck" ] 
then
	echo "[" >> ~/people.json
fi


# remove closing brackets at end of json file (ex }]) should be last two lines, also check to see if it is a new file.
linecount=$( cat ~/people.json | wc -l )
if [ $linecount -gt 2 ]
then
	sed -i '$ d' ~/people.json
	sed -i '$ d' ~/people.json
        echo "        }," >> ~/people.json
fi
	

#Create the template
cat << EOF > ~/.people.json.template
        {
         "name": "$name",
         "avatar": "$avatar",
         "city": "$city",
         "gravatar": "$gravatar",
         "github": "$github",
         "tz": "$tz"
    }
EOF
#check for null values, remove lines from template
if [ -z $name ]
then
	sed -i 's/\"name\".*//' ~/.people.json.template
fi
if [ -z $avatar ]
then
	sed -i 's/\"avatar\".*//' ~/.people.json.template
fi
if [ -z $gravatar ]
then
	sed -i 's/\"gravatar\".*//' ~/.people.json.template
fi
if [ -z $github ]
then
	sed -i 's/\"github\".*//' ~/.people.json.template
fi
if [ -z $city ]
then
	sed -i 's/\"city\".*//' ~/.people.json.template
fi

# remove all empty lines, not new lines
sed -i '/^ *$/d' ~/.people.json.template

#cat the files togather
cat ~/people.json ~/.people.json.template > ~/.temp.json

#create new people.json
rm ~/people.json
mv ~/.temp.json ~/people.json
rm ~/.people.json.template
echo "]" >> ~/people.json
