namespace OneTruePath.Domain
{
    public interface IStoryNavigator
    {
        string GoBack();
        string GoForward(int optionNumber);
        string Refresh();
    }
}