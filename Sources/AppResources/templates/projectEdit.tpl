<div class="row">
    <div class="col-3 pt-2">
        <div class="pl-3 m-2 font-14 {css}">
            <div style="margin-left:0px;">
                <i data-feather="chevron-down" style="height:14px"></i>  <i data-feather="layers" class="mx-2" style="height: 16px;"></i> <a href="/editProject?projectID={projectID}">{projectName}</a>
            </div>
        </div>
        [START treeGroup]
        <div class="pl-3 m-2 font-14 {css}">
            <div style="margin-left:{margin}px;">
                <i data-feather="chevron-{side}" style="height:14px"></i>  <i data-feather="{icon}" class="mx-2" style="height: 16px;"></i> <a href="{url}">{name}</a>
                 </div>
        </div>
        [END treeGroup]
    </div>
    <div class="col-9">
        {cards}
            
        {table}
    </div>
</div>
[START addGroup]
<div style="width: 100%; height: 100%; position: absolute; top: 0; left: 0; margin: 0; padding: 0; background: rgba(128, 128, 128, .5)">
    <div class="float-right p-4" style="width: 500px; height: 100%; background-color: white; ">
    <p>Dodaj grupę</p>
    {form}
</div>
[END addGroup]
[START addParameter]
<div style="width: 100%; height: 100%; position: absolute; top: 0; left: 0; margin: 0; padding: 0; background: rgba(128, 128, 128, .5)">
    <div class="float-right p-4" style="width: 800px; height: 100%; background-color: white; ">
    <p>Dodaj Parametr</p>
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
