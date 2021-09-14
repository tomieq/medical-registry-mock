<div class="row">
    <div class="col-2 pt-2">
        <div class="pl-3 font-14 {css}">
                 <span class="font-22">›</span>  <i data-feather="layers" class="mx-2" style="height: 16px;"></i> <a href="/editProject?projectID={projectID}">{projectName}</a>
        </div>
        [START group]
        <div class="pl-3 font-14 {css}">
                 <span class="font-22">›</span>  <i data-feather="file-text" class="mx-2" style="height: 16px;"></i> <a href="/editProject?projectID={projectID}&groupID={groupID}">{name}</a>
        </div>
        [END group]
    </div>
    <div class="col-10">{cards}</div>
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
