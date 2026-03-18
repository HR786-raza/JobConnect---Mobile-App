import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/models/application_model.dart';
import 'package:jobconnect/utils/helpers.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class GenerateLetterScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const GenerateLetterScreen({super.key, required this.arguments});

  @override
  State<GenerateLetterScreen> createState() => _GenerateLetterScreenState();
}

class _GenerateLetterScreenState extends State<GenerateLetterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _templates = [];
  Map<String, dynamic>? _selectedTemplate;
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _candidateNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();
  
  String _letterType = 'joining'; // 'joining' or 'internship'
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _letterType = widget.arguments['letterType'] ?? 'joining';
    _loadTemplates();
    _populateData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _candidateNameController.dispose();
    _positionController.dispose();
    _startDateController.dispose();
    _salaryController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _loadTemplates() {
    // Load templates from database or use defaults
    setState(() {
      _templates.addAll([
        {
          'id': '1',
          'name': 'Standard Joining Letter',
          'type': 'joining',
          'content': '''
Dear {candidate_name},

We are pleased to offer you the position of {position} at {company_name}. We were impressed with your skills and experience, and we believe you will be a valuable addition to our team.

Position Details:
- Position: {position}
- Start Date: {start_date}
- Location: {location}
- Salary: {salary} per annum

Please find attached the detailed offer letter with complete terms and conditions. Kindly sign and return a copy of this letter by {deadline} to accept this offer.

We look forward to welcoming you to our team!

Best regards,
{employer_name}
{company_name}
          ''',
        },
        {
          'id': '2',
          'name': 'Professional Joining Letter',
          'type': 'joining',
          'content': '''
{company_name}
{company_address}

Date: {current_date}

To,
{candidate_name}
{candidate_address}

Subject: Offer of Employment for the position of {position}

Dear {candidate_name},

We are delighted to extend an offer of employment for the position of {position} at {company_name}. This letter confirms the terms and conditions of your employment.

Employment Details:
- Position: {position}
- Department: {department}
- Reporting to: {manager_name}
- Start Date: {start_date}
- Work Location: {location}
- Compensation: {salary} per annum
- Benefits: As per company policy

Please complete the attached documents and return them by {deadline}. If you have any questions, please don't hesitate to contact us.

We are excited about the possibility of you joining our team!

Sincerely,
{employer_name}
HR Manager
{company_name}
          ''',
        },
        {
          'id': '3',
          'name': 'Internship Certificate',
          'type': 'internship',
          'content': '''
INTERNSHIP COMPLETION CERTIFICATE

This is to certify that {candidate_name} has successfully completed an internship at {company_name} from {start_date} to {end_date}.

During this internship, {candidate_name} worked as a {position} and demonstrated exceptional skills in {skills}. They worked on various projects including {projects} and showed great dedication and professionalism.

We wish {candidate_name} all the best in their future endeavors.

Date: {current_date}

{employer_name}
{company_name}
          ''',
        },
        {
          'id': '4',
          'name': 'Internship Offer Letter',
          'type': 'internship',
          'content': '''
Dear {candidate_name},

We are pleased to offer you an internship position as {position} at {company_name}. We believe this internship will provide you with valuable experience in {field}.

Internship Details:
- Position: {position}
- Duration: {duration} months
- Start Date: {start_date}
- End Date: {end_date}
- Stipend: {stipend} per month
- Working Hours: {working_hours} hours per week

Please confirm your acceptance by {deadline}. We look forward to having you on board!

Best regards,
{employer_name}
{company_name}
          ''',
        },
      ]);

      _selectedTemplate = _templates.firstWhere(
        (t) => t['type'] == _letterType,
        orElse: () => _templates.first,
      );
    });
  }

  void _populateData() {
    final applicant = widget.arguments['applicant'] as ApplicationModel;
    
    setState(() {
      _candidateNameController.text = applicant.applicantName;
      _positionController.text = applicant.jobTitle;
      _companyNameController.text = applicant.employerName ?? '';
      
      // Set default start date to 2 weeks from now
      final startDate = DateTime.now().add(const Duration(days: 14));
      _startDateController.text = Helpers.formatDate(startDate);
      _selectedDate = startDate;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDateController.text = Helpers.formatDate(picked);
      });
    }
  }

  String _generateLetterContent() {
    if (_selectedTemplate == null) return '';

    String content = _selectedTemplate!['content'];
    
    // Replace placeholders
    content = content.replaceAll('{candidate_name}', _candidateNameController.text);
    content = content.replaceAll('{company_name}', _companyNameController.text);
    content = content.replaceAll('{position}', _positionController.text);
    content = content.replaceAll('{start_date}', _startDateController.text);
    content = content.replaceAll('{current_date}', Helpers.formatDate(DateTime.now()));
    content = content.replaceAll('{salary}', _salaryController.text.isNotEmpty ? _salaryController.text : '[Salary]');
    content = content.replaceAll('{deadline}', Helpers.formatDate(DateTime.now().add(const Duration(days: 7))));
    content = content.replaceAll('{employer_name}', 'Hiring Manager');
    content = content.replaceAll('{location}', 'New York, NY');
    content = content.replaceAll('{company_address}', '123 Business Ave, Suite 100');
    content = content.replaceAll('{candidate_address}', '[Candidate Address]');
    content = content.replaceAll('{department}', 'Engineering');
    content = content.replaceAll('{manager_name}', 'John Smith');
    content = content.replaceAll('{skills}', 'Flutter, Dart, Firebase');
    content = content.replaceAll('{projects}', 'JobConnect Mobile App');
    content = content.replaceAll('{end_date}', Helpers.formatDate(DateTime.now().add(const Duration(days: 90))));
    content = content.replaceAll('{field}', 'Mobile Development');
    content = content.replaceAll('{duration}', '3');
    content = content.replaceAll('{stipend}', '\$2,000');
    content = content.replaceAll('{working_hours}', '40');
    
    return content;
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final content = _generateLetterContent();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _letterType == 'joining' ? 'Joining Letter' : 'Internship Letter',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                content,
                style: const pw.TextStyle(
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save or share PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${_letterType}_letter_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> _saveTemplate() async {
    // Save custom template logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicant = widget.arguments['applicant'] as ApplicationModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(_letterType == 'joining' ? 'Generate Joining Letter' : 'Generate Internship Letter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Edit', icon: Icon(Icons.edit)),
            Tab(text: 'Preview', icon: Icon(Icons.preview)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
            tooltip: 'Save as template',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Edit Tab
          _buildEditTab(applicant),
          
          // Preview Tab
          _buildPreviewTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Generate PDF',
                  onPressed: _generatePDF,
                  icon: Icons.picture_as_pdf,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Send Email',
                  onPressed: () {
                    // Send email logic
                  },
                  icon: Icons.email,
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditTab(ApplicationModel applicant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Template',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _templates
                        .where((t) => t['type'] == _letterType)
                        .map((template) {
                      final isSelected = _selectedTemplate?['id'] == template['id'];
                      return ChoiceChip(
                        label: Text(template['name']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTemplate = template;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Company Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Company Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Candidate Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Candidate Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _candidateNameController,
                    decoration: const InputDecoration(
                      labelText: 'Candidate Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Candidate Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Employment Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _letterType == 'joining' ? 'Employment Details' : 'Internship Details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Start Date
                  TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Salary/Stipend
                  TextFormField(
                    controller: _salaryController,
                    decoration: InputDecoration(
                      labelText: _letterType == 'joining' ? 'Salary (Annual)' : 'Stipend (Monthly)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  if (_letterType == 'joining') ...[
                    // Department
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reporting Manager
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Reporting Manager',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...[
                    // Duration
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Duration (months)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Working Hours/Week',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _additionalNotesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Add any special instructions, benefits, or notes...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    final content = _generateLetterContent();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _letterType == 'joining' ? 'Joining Letter' : 'Internship Letter',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}