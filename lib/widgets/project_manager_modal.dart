import 'package:flutter/material.dart';
import '../models/project_file.dart';

class ProjectManagerModal extends StatelessWidget {
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

          // 列表展现
          ...ProjectFile.sampleProjects.map((project) {
            final isSelected = project.id == selectedProject.id;

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
                      '文件: ${project.fileName}\n预估时间: ${project.estimatedTime} | 建议材料: ${project.recommendedMaterial}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blueAccent)
                      : OutlinedButton(
                          onPressed: () {
                            onProjectSelected(project);
                            Navigator.pop(context);
                          },
                          child: const Text('载入'),
                        ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
