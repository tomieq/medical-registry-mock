<div class="row">
    <div class="col-3 pt-2">
        <div class="pl-3 font-14 {css}">
            <i data-feather="chevron-right" style="height:14px"></i>  <i data-feather="layers" class="mx-2" style="height: 16px;"></i> <a href="/editProject?projectID={projectID}">{projectName}</a>
        </div>
        [START treeGroup]
        <div class="pl-3 m-2 font-14 {css}">
                 <div style="margin-left:{margin}px;">
                    <i data-feather="chevron-{side}" style="height:14px"></i>  <i data-feather="file-text" class="mx-2" style="height: 16px;"></i> <a href="{url}">{name}</a>
                 </div>
        </div>
        [END treeGroup]
    </div>
    <div class="col-9">
        {cards}
            
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">GRUPY PYTAŃ</th>
              <th scope="col">CZY GRUPĘ MOŻNA KOPIOWAĆ</th>
              <th scope="col">ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            [START groupItem]
            <tr>
              <td><i data-feather="folder" class="text-light-gray mx-2" style="height: 16px;"></i> <a href="/editProject?projectID={projectID}" class="text-gray">{name}</a></td>
              <td><input type="checkbox" /></td>
              <td>
                <div class="dropdown">
                  <button class="btn text-light-gray" type="button" id="dropdownMenuButton{groupID}" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i data-feather="more-vertical" class="mx-2" style="height: 16px;"></i>
                  </button>
                  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton{groupID}">
                    <a class="dropdown-item font-14 text-light-gray" href="{renameURL}">Zmień nazwę</a>
                    <a class="dropdown-item font-14 text-light-gray" href="{deleteURL}">Usuń</a>
                  </div>
                </div>
              </td>
            </tr>
            [END groupItem]
          </tbody>
        </table>
    </div>
</div>
[START addGroup]
<div style="width: 100%; height: 100%; position: absolute; top: 0; left: 0; margin: 0; padding: 0; background: rgba(128, 128, 128, .5)">
    <div class="float-right p-4" style="width: 500px; height: 100%; background-color: white; ">
    <p>Dodaj grupę</p>
    {form}
</div>
[END addGroup]


<style>
.treeItemActive {
        border-left: 4px solid #7367F0
}
.treeItemInactive {
        border-left: 4px solid #fff
}
</style>
