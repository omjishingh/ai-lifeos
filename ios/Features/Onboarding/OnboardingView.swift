import SwiftUI

struct OnboardingView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.appColors) private var colors
    @State private var viewModel: OnboardingViewModel?

    var body: some View {
        Group {
            if let viewModel {
                onboardingContent(viewModel)
            } else {
                LoadingView(message: "Preparing onboarding...")
            }
        }
        .onAppear { setupViewModel() }
    }

    private func onboardingContent(_ viewModel: OnboardingViewModel) -> some View {
        VStack(spacing: 0) {
            if viewModel.currentStep != .welcome {
                progressBar(viewModel)
            }

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    stepContent(viewModel)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.lg)
                }
            }

            navigationButtons(viewModel)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
        }
        .background(colors.background)
    }

    private func progressBar(_ viewModel: OnboardingViewModel) -> some View {
        VStack(spacing: AppSpacing.xs) {
            ProgressView(value: viewModel.currentStep.progress)
                .tint(colors.accent)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
                .accessibilityLabel("Onboarding progress \(Int(viewModel.currentStep.progress * 100)) percent")

            Text("Step \(viewModel.currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
                .font(AppTypography.caption)
                .foregroundStyle(colors.secondaryText)
        }
    }

    @ViewBuilder
    private func stepContent(_ viewModel: OnboardingViewModel) -> some View {
        switch viewModel.currentStep {
        case .welcome:
            WelcomeStepView()
        case .name:
            NameStepView(name: Bindable(viewModel).name)
        case .wakeTime:
            WakeTimeStepView(wakeUpTime: Bindable(viewModel).wakeUpTime)
        case .sleepTime:
            SleepTimeStepView(sleepTime: Bindable(viewModel).sleepTime)
        case .collegeSchedule:
            CollegeScheduleStepView(
                startTime: Bindable(viewModel).collegeStartTime,
                endTime: Bindable(viewModel).collegeEndTime,
                sundayIsHoliday: Bindable(viewModel).sundayIsHoliday
            )
        case .travelTime:
            TravelTimeStepView(travelMinutes: Bindable(viewModel).travelMinutes)
        case .codingTarget:
            CodingTargetStepView(codingTargetMinutes: Bindable(viewModel).codingTargetMinutes)
        case .notifications:
            NotificationsStepView(notificationsEnabled: Bindable(viewModel).notificationsEnabled)
        case .aiPreferences:
            AIPreferencesStepView(
                aiEnabled: Bindable(viewModel).aiEnabled,
                newsNotificationTime: Bindable(viewModel).newsNotificationTime
            )
        case .sleepMusic:
            SleepMusicStepView(sleepMusicPreference: Bindable(viewModel).sleepMusicPreference)
        case .finish:
            FinishStepView(
                summary: viewModel.reviewSummary,
                errorMessage: viewModel.errorMessage
            )
        }
    }

    private func navigationButtons(_ viewModel: OnboardingViewModel) -> some View {
        VStack(spacing: AppSpacing.sm) {
            if let error = viewModel.errorMessage, viewModel.currentStep == .finish {
                Text(error)
                    .font(AppTypography.caption)
                    .foregroundStyle(colors.error)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: AppSpacing.sm) {
                if viewModel.currentStep.previous != nil {
                    SecondaryButton("Back", icon: "chevron.left") {
                        viewModel.goBack()
                    }
                }

                PrimaryButton(
                    primaryButtonTitle(viewModel),
                    icon: primaryButtonIcon(viewModel),
                    isLoading: viewModel.isFinishing
                ) {
                    Task { await viewModel.goNext() }
                }
                .disabled(!viewModel.canProceed || viewModel.isFinishing)
            }
        }
    }

    private func primaryButtonTitle(_ viewModel: OnboardingViewModel) -> String {
        switch viewModel.currentStep {
        case .welcome: return "Get Started"
        case .finish: return "Build My Schedule"
        default: return "Continue"
        }
    }

    private func primaryButtonIcon(_ viewModel: OnboardingViewModel) -> String? {
        switch viewModel.currentStep {
        case .welcome: return "arrow.right"
        case .finish: return "calendar.badge.plus"
        default: return "chevron.right"
        }
    }

    private func setupViewModel() {
        guard let appEnvironment, viewModel == nil else { return }
        viewModel = OnboardingViewModel(
            settingsRepository: appEnvironment.settingsRepository,
            scheduleRepository: appEnvironment.scheduleRepository,
            streakRepository: appEnvironment.streakRepository,
            sleepRepository: appEnvironment.sleepRepository,
            routineGenerator: appEnvironment.routineGenerator,
            notificationScheduler: appEnvironment.notificationScheduler,
            missedTaskService: appEnvironment.missedTaskService
        ) {
            appEnvironment.loadInitialState()
        }
    }
}

#Preview {
    OnboardingView()
        .environment(\.appEnvironment, try! AppEnvironment(modelContainer: makeModelContainer(inMemory: true)))
}
