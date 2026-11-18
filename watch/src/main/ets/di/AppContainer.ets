import { bundleManager, common } from '@kit.AbilityKit';
import { NfcDiscoveryDataSource } from '../data/nfc/NfcDiscoveryDataSource';
import { NfcRepositoryImpl } from '../data/repository/NfcRepositoryImpl';
import { NfcRepository } from '../domain/repository/NfcRepository';
import { CancelNfcOperationUseCase } from '../domain/usecase/CancelNfcOperationUseCase';
import { CheckNfcStateUseCase } from '../domain/usecase/CheckNfcStateUseCase';
import { ReadNfcTagUseCase } from '../domain/usecase/ReadNfcTagUseCase';
import { WriteNfcTagUseCase } from '../domain/usecase/WriteNfcTagUseCase';

/** Manual dependency injection: the single place that wires data -> domain. */
export class AppContainer {
  private static instance: AppContainer | undefined = undefined;

  readonly readNfcTag: ReadNfcTagUseCase;
  readonly writeNfcTag: WriteNfcTagUseCase;
  readonly cancelNfcOperation: CancelNfcOperationUseCase;

  private constructor(context: common.UIAbilityContext) {
    const element: bundleManager.ElementName = {
      bundleName: context.abilityInfo.bundleName,
      moduleName: context.abilityInfo.moduleName,
      abilityName: context.abilityInfo.name
    };
    const repository: NfcRepository = new NfcRepositoryImpl(new NfcDiscoveryDataSource(element));
    const checkState = new CheckNfcStateUseCase(repository);
    this.readNfcTag = new ReadNfcTagUseCase(repository, checkState);
    this.writeNfcTag = new WriteNfcTagUseCase(repository, checkState);
    this.cancelNfcOperation = new CancelNfcOperationUseCase(repository);
  }

  /** Call once from the UIAbility before any page loads. */
  static init(context: common.UIAbilityContext): void {
    AppContainer.instance = new AppContainer(context);
  }

  static get(): AppContainer {
    if (AppContainer.instance === undefined) {
      throw new Error('AppContainer.init() has not been called');
    }
    return AppContainer.instance;
  }
}
