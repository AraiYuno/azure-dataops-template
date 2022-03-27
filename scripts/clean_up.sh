set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace # For debugging


###################
# PARAMETERS
#
# RESOURCE_GROUP_NAME_PREFIX
prefix="anvil-dm"

echo "!! WARNING: !!"
echo "THIS SCRIPT WILL DELETE RESOURCES PREFIXED WITH $prefix !!"

if [[ -n $prefix ]]; then

    printf "\nPIPELINES:\n"
    az pipelines list -o tsv --only-show-errors | { grep "$prefix" || true; } | awk '{print $8}'
    
    printf "\nVARIABLE GROUPS:\n"
    az pipelines variable-group list -o tsv --only-show-errors | { grep "$prefix" || true; } | awk '{print $6}'
    
    printf "\nSERVICE CONNECTIONS:\n"
    az devops service-endpoint list -o tsv --only-show-errors | { grep "$prefix" || true; } | awk '{print $6}'
    
    printf "\nSERVICE PRINCIPALS:\n"
    az ad sp list --query "[?contains(appDisplayName,'$prefix')].displayName" -o tsv --show-mine
    
    printf "\nRESOURCE GROUPS:\n"
    az group list --query "[?contains(name,'$prefix') && ! contains(name,'dbw')].name" -o tsv

    printf "\nEND OF SUMMARY\n"


    read -r -p "Do you wish to DELETE above? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "Delete pipelines the start with '$prefix' in name..."
            [[ -n $prefix ]] &&
                az pipelines list -o tsv |
                { grep "$prefix" || true; } |
                awk '{print $4}' |
                xargs -r -I % az pipelines delete --id % --yes

            echo "Delete variable groups the start with '$prefix' in name..."
            [[ -n $prefix ]] &&
                az pipelines variable-group list -o tsv |
                { grep "$prefix" || true; } | 
                awk '{print $3}' |
                xargs -r -I % az pipelines variable-group delete --id % --yes

            echo "Delete service connections the start with '$prefix' in name..."
            [[ -n $prefix ]] &&
                az devops service-endpoint list -o tsv |
                { grep "$prefix" || true; } |
                awk '{print $3}' |
                xargs -r -I % az devops service-endpoint delete --id % --yes

            echo "Delete service principal the start with '$prefix' in name, created by yourself..."
            [[ -n $prefix ]] &&
                az ad sp list --query "[?contains(appDisplayName,'$prefix')].appId" -o tsv --show-mine | 
                xargs -r -I % az ad sp delete --id %

            echo "Delete resource group the start with '$prefix' in name..."
            [[ -n $prefix ]] &&
                az group list --query "[?contains(name,'$prefix') && ! contains(name,'dbw')].name" -o tsv |
                xargs -I % az group delete --verbose --name % -y
            ;;
        *)
            exit
            ;;
    esac
fi