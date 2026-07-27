import 'package:flutter/material.dart';
import '../models/project_file.dart';
import '../services/file_import_service.dart';

class ProjectManagerModal extends StatefulWidget {
  final ProjectFile selectedProject;
  final ValueChanged<ProjectFile> onProjectSelected;

  const ProjectManagerModal({
    Super.key,
    required this.selectedProject,
    required this.onProjectSelected,
  });

  static void show({
    required BuildContext context,
    required ProjectFile current,
    required ValueChanged<ProjectFile> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProjectManagerModal(
        selectedProject: current,
        onProjectSelected: onSelected,
      ),
    );
  }

  @override
  State<ProjectManagerModal> createState() => _ProjectManagerModalState();
}

class _ProjectManagerModalState extends State<ProjectManagerModal> {
  late List<ProjectFile> _projectList;

  @override
  void initState() {
    super.initState();
    // 初始化列表（含官方预设）
    _projectList = List.from(ProjectFile.sampleProjects);
  }

  void _importLocalFile() {
    // 模拟触发文件选择器并成功解析导入
    final newProject = FileImportService.getMockImportedFile();

    setState(() {
      _projectList.insert(0, newProject);
    });

    widget.onProjectSelected(newProject);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已成功导入并载入文件：${newProject.fileName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('工程文件选择', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. 虚线按钮：导入本地 G-code 文件 (.nc / .gcode)
          InkWell(
            onTap: _importLocalFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.5),
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_upload_outlined, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    '导入本地 G-code / .nc 文件',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. 工程文件列表（含预设 + 已导入）
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _projectList.length,
              itemBuilder: (context, index) {
                final project = _projectList[index];
                final isSelected = project.id == widget.selectedProject.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                        : const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.blueAccent : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Colors.blueAccent : Colors.white10,
                        child: Icon(project.icon, color: Colors.white),
                      ),
                      title: Text(
                        project.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '文件: ${project.fileName}\n预估用时: ${project.estimatedTime} | ${project.recommendedMaterial}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blueAccent)
                          : OutlinedButton(
                              onPressed: () {
                                widget.onProjectSelected(project);
                                Navigator.pop(context);
                              },
                              child: const Text('载入'),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
